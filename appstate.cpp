#include <utility>

#include "appstate.h"

AppState::AppState(QObject *parent, RenderThread *thread) : QObject(parent) {
  m_color = QColor();
  m_color.setHsvF(m_hue, m_saturation, m_lightness, m_opacity);

  m_image = QImage(LED_SIZE, LED_SIZE, QImage::Format_ARGB32_Premultiplied);
  m_image.fill(Qt::transparent);
  m_last_point = nullptr;

  m_glitch_timer = new GlitchTimer(this);
  connect(m_glitch_timer, &GlitchTimer::glitchStarted, this, &AppState::onGlitchStarted);
  connect(m_glitch_timer, &GlitchTimer::glitchCompleted, this, &AppState::onGlitchCompleted);
  connect(m_glitch_timer, &GlitchTimer::imageChanged, this, &AppState::onImageChanged);

  m_timer = new QTimer(this);
  connect(m_timer, &QTimer::timeout, this, &AppState::updateCountdown);
  restartCountdown();

  m_renderThread = thread;
  swapBuffer();

  m_renderThread->render(m_image);
}

AppState::~AppState() {
  delete m_renderThread;
  m_timer->stop();
  delete m_timer;
  delete m_glitch_timer;
}

void AppState::setHue(qreal hue) {
  // comparing doubles in c++ is weird
  if (fabs(hue - m_hue) >= std::numeric_limits<double>::epsilon()) {
    m_hue = hue;
    emit hueChanged();
  }
}

qreal AppState::hue() const {
  return m_hue;
}

void AppState::setColor(QColor &color) {
  if (color != m_color) {
    m_color = color;
    emit colorChanged();
  }
}

QColor AppState::color() const {
  return m_color;
}

// Return the opaque color
QColor AppState::colorOpaque() const {
  QColor newColor = QColor(m_color);
  newColor.setAlphaF(1.);
  return newColor;
}

void AppState::swapBuffer() {
  m_image_source = QImage(m_image);
  m_image_layer = QImage(m_image);
  m_image_layer.fill(QColor(0, 0, 0, 0));
  m_last_point = nullptr;

// Useful for saving an image
//  QImageWriter writer("/images/layer.png", "PNG");
//  qInfo("%d", writer.write(m_image_layer));
//  QString boop(writer.errorString());
//  qInfo(boop.toLatin1());
}

void AppState::updateBrush() {
  QImage qpix(m_brush.size, m_brush.size, QImage::Format_ARGB32_Premultiplied);
  qpix.fill(Qt::transparent);
  QPainter paint;
  paint.begin(&qpix);
  switch (m_brush.type) {
    case Brush::circle: {
      QRadialGradient gradient(m_brush.size/2., m_brush.size/2., m_brush.size);
      gradient.setColorAt(0, m_color);
      gradient.setColorAt(m_brush.hardness/2., m_color);
      QColor newColor(m_color);
      newColor.setAlphaF(0.);
      gradient.setColorAt(.51, newColor);
      QBrush brush(gradient);
      paint.setBrush(brush);
      paint.fillRect(0, 0, m_brush.size, m_brush.size, brush);
      break;
    }
    case Brush::square: {
      paint.fillRect(0, 0, m_brush.size, m_brush.size, m_color);
      break;
    }
    default:
      break;
  }
  paint.end();
  m_brush_source = qpix;
}

void AppState::drawFromCoordinates(double x, double y, double width, double height) {
  QPoint point(
    qRound(qBound(0., x / width, 1.) * LED_SIZE),
    qRound(qBound(0., y / height, 1.) * LED_SIZE)
  );

  //TODO: Make color selector circle bobble big on drag like Procreate
  //TODO: Add cool circle thingie to HSBSpectrum (https://www.shadertoy.com/view/ltBXRc)

  // Create a new layer and paint onto it
  // This technique is unlike to work for large images :/
  QImage new_layer(m_image_layer.size(), QImage::Format_ARGB32_Premultiplied);
  new_layer.fill(Qt::transparent);
  QPainter paint;
  paint.begin(&new_layer);
  int half_brush_size = m_brush.size/2;

  if (m_last_point == nullptr) {
    paint.drawImage(point.x()-half_brush_size, point.y()-half_brush_size, m_brush_source);
  } else {
    QLineF line(m_last_point->x(), m_last_point->y(), point.x(), point.y());
    qreal length = line.length();
    qreal increment = length/100;
    QImage temp_layer(m_image_layer.size(), QImage::Format_ARGB32_Premultiplied);
    temp_layer.fill(Qt::transparent);
    for (qreal x = 0.0001; x <= length; x += increment) {
      QImage line_layer(m_image_layer.size(), QImage::Format_ARGB32_Premultiplied);
      line_layer.fill(Qt::transparent);
      QPainter linePainter;
      linePainter.begin(&line_layer);
      QPointF targetPoint(line.pointAt(x / length));
      linePainter.drawImage(
        static_cast<int>(targetPoint.x())-half_brush_size,
        static_cast<int>(targetPoint.y())-half_brush_size,
        m_brush_source);
      linePainter.end();
      temp_layer = GraphicsUtils::mergeImages(temp_layer, line_layer, m_color.alpha());
    }
    paint.drawImage(new_layer.rect(), temp_layer);
  }
  paint.end();

  delete m_last_point;
  m_last_point = new QPoint(point.x(), point.y());

  // Merge the new layer and do not allow it to go above alpha threhold (acts like photoshop)
  m_image_layer = GraphicsUtils::mergeImages(m_image_layer, new_layer, m_color.alpha());

  // Paint m_image_layer onto copied m_image_source
  // and update m_image
  QImage original(m_image_source);
  paint.begin(&original);
  paint.drawImage(m_image_layer.rect(), m_image_layer);
  paint.end();
  m_image = original;

  emit imageChanged();

  restartCountdown();
  m_renderThread->render(m_image);
}

void AppState::setColorFromCoordinates(double x, double y, double width, double height) {
  // Matches algorithm in glsl shader in HSBSpectrum
  setSaturationF(qBound(0., x / width, 1.));
  setLightnessF(qBound(0., 1 - (y / height), 1.));
  QColor newColor = QColor();
  newColor.setHsvF(hue(), m_saturation, m_lightness, m_opacity);
  setColor(newColor);
}

void AppState::setHueFromCoordinates(double y, double height) {
  // Matches algorithm in glsl shader in HueGradient
  qreal hue = qBound(0., y / height, 1.);
  QColor newColor = QColor();
  newColor.setHsvF(hue, m_saturation, m_lightness, m_opacity);
  setColor(newColor);
  setHue(hue);
}

void AppState::setOpacityFromCoordinates(double y, double height) {
  setOpacity(qBound(0., y / height, 1.));
  QColor newColor = QColor();
  newColor.setHsvF(m_hue, m_saturation, m_lightness, m_opacity);
  setColor(newColor);
}

void AppState::setSaturationF(qreal saturation) {
  m_saturation = saturation;
}

qreal AppState::saturationF() const {
  return m_saturation;
}

void AppState::setLightnessF(qreal lightness) {
  m_lightness = lightness;
}

qreal AppState::lightnessF() const {
  return m_lightness;
}

void AppState::setOpacity(qreal opacity) {
  if (fabs(opacity - m_opacity) >= std::numeric_limits<double>::epsilon()) {
    m_opacity = opacity;
    emit opacityChanged();
  }
}

qreal AppState::opacity() const {
  return m_opacity;
}

QImage AppState::image() const {
  return m_image;
}

void AppState::setBrush(const BrushAnatomy& brush) {
  m_brush = brush;
  emit brushChanged();
}

BrushAnatomy AppState::brush() const {
  return m_brush;
}

void AppState::setBrushSize(int size) {
  m_brush.size = size;
  emit brushChanged();
}

void AppState::setBrushHardness(qreal hardness) {
  m_brush.hardness = hardness;
  emit brushChanged();
}

void AppState::setBrushType(int type) {
  // totally lame that we can't use the native enum from QML
  switch(type) {
    case 0:
      m_brush.type = Brush::circle;
      break;
    case 1:
      m_brush.type = Brush::square;
      break;
    default:
      break;
  }

  emit brushChanged();
}

void AppState::clearCanvas() {
  m_image.fill(Qt::transparent);
  swapBuffer();
  emit imageChanged();
  restartCountdown();
  m_renderThread->render(m_image);
}

QString AppState::formatPopupLabel(int seconds, const QString& format) const {
  QTime time = QTime(0,0,0,0);
  return time.addSecs(seconds).toString(format);
}

QString AppState::formatTime(int seconds, const QString& format) const {
  QTime time = QTime(0,0,0,0);
  return time.addSecs(seconds).addMSecs(1000 - m_elapsedTimer.elapsed()).toString(format);
}

QString AppState::countdownLabel() const {
  return formatTime(m_countdown - 1, "m:ss");
}

QString AppState::countdownMsLabel() const {
  return formatTime(m_countdown, ".z");
}

qreal AppState::getCountProgress() {
  float percent =
      1. - static_cast<float>((m_countdown - 1) * 1000 + 1000 - m_elapsedTimer.elapsed())
      / static_cast<float>(m_countdownTotal * 1000);
  return std::max(GraphicsUtils::getGlitchAmountForCountdown(percent), 0.);
}

void AppState::restartCountdown() {
  m_countdown = m_countdownTotal;
  m_timer->start(24);
  m_elapsedTimer.restart();
  emit countdownChanged();
}

void AppState::updateCountdown() {
  if (m_elapsedTimer.elapsed() >= 1000) {
    m_countdown--;
    m_elapsedTimer.restart();
  }

  if (m_countdown <= 0) {
    emit glitchImminent();
    m_timer->stop();
    m_glitch_timer->run(m_image);
  }
  emit countdownChanged();
}

void AppState::onGlitchStarted() {

}

void AppState::onGlitchCompleted() {
  swapBuffer();
  restartCountdown();
}

void AppState::onImageChanged(QImage image) {
  m_image = QImage(std::move(image));
  emit imageChanged();
  m_renderThread->render(m_image);
}


void AppState::setCountdownTotal(int total) {
  m_countdownTotal = total;
  restartCountdown();
  emit countdownTotalChanged();
}

int AppState::countdownTotal() const {
  return m_countdownTotal;
}

qreal AppState::getOffset(qreal base, qreal scale) {
  return (scale * base - base) / 2.;
}

void AppState::setMiniDisplayValue(double x, double y, double width, double height, double scale) {
  qreal rootX = getOffset(width, scale) - x;
  qreal rootY = getOffset(height, scale) - y;

  m_miniDisplayValue = MiniDisplay(
    (width / scale) / width,
    (height / scale) / height,
    std::max(0., (rootX / scale) / width),
    std::max(0., (rootY / scale) / height)
  );

  emit miniDisplayValueChanged();
}

MiniDisplay AppState::miniDisplayValue() {
  return m_miniDisplayValue;
}
