#include "glitchpainter.h"

GlitchPainter::GlitchPainter(QObject *parent) : QObject(parent)
{
    format.setVersion(2, 0);
    surface.setFormat(format);
    surface.create();

    context.setFormat(format);
    if (!context.create()) {
        qFatal("Cannot create the requested OpenGL context!");
    }
    context.makeCurrent(&surface);
    initializeOpenGLFunctions();

    fboFormat.setSamples(16);
    fboFormat.setAttachment(QOpenGLFramebufferObject::CombinedDepthStencil);
}

void GlitchPainter::nativePainting(
    QOpenGLFramebufferObject &fbo,
    std::vector<ShiftRange> &ranges,
    qreal percent = .64,
    int time = 1000,
    qreal glitchScale = .5) {

    QOpenGLShaderProgram program;

    program.addShaderFromSourceFile(QOpenGLShader::Vertex, QStringLiteral(":/shaders/default.vsh"));
    program.addShaderFromSourceFile(QOpenGLShader::Fragment, QStringLiteral(":/shaders/glitch.fsh"));

    program.bindAttributeLocation("qt_Vertex", 0);
    program.bindAttributeLocation("qt_MultiTexCoord0", 1);

    program.link();
    program.bind();

    int numRangesLocation = program.uniformLocation("numRanges");
    int shiftAmountLocation = program.uniformLocation("shiftAmount");

    int matrixLocation = program.uniformLocation("qt_Matrix");
    int resolutionLocation = program.uniformLocation("iResolution");
    int timeLocation = program.uniformLocation("iTime");
    int glitchScaleLocation = program.uniformLocation("glitchScale");
    int percentLocation = program.uniformLocation("percent");

    static QSize size(fbo.size());
    static QPointF p0(size.width(), size.height());
    static QPointF p1(0, 0);
    static QPointF p2(0, size.height());
    static QPointF p3(size.width(), 0);

    static GLfloat vertices[6 * 2] = {
        GLfloat(p0.x()), GLfloat(p0.y()),
        GLfloat(p1.x()), GLfloat(p1.y()),
        GLfloat(p2.x()), GLfloat(p2.y()),

        GLfloat(p0.x()), GLfloat(p0.y()),
        GLfloat(p3.x()), GLfloat(p3.y()),
        GLfloat(p1.x()), GLfloat(p1.y()),
    };

    static GLfloat textureCoords[6 * 2] = {
        1., 1.,
        0., 0.,
        0., 1.,

        1., 1.,
        1., 0.,
        0., 0.,
    };

    QOpenGLBuffer vertexPositionBuffer(QOpenGLBuffer::VertexBuffer);
    vertexPositionBuffer.create();
    vertexPositionBuffer.setUsagePattern(QOpenGLBuffer::StaticDraw);
    vertexPositionBuffer.bind();
    vertexPositionBuffer.allocate(vertices, 12 * sizeof(GLfloat));

    QOpenGLBuffer textureCoordinatesBuffer(QOpenGLBuffer::VertexBuffer);
    textureCoordinatesBuffer.create();
    textureCoordinatesBuffer.setUsagePattern(QOpenGLBuffer::StaticDraw);
    textureCoordinatesBuffer.bind();
    textureCoordinatesBuffer.allocate(textureCoords, 12 * sizeof(GLfloat));

    QMatrix4x4 pmvMatrix;
    pmvMatrix.ortho(QRect(0, 0, size.width(), size.height()));

    vertexPositionBuffer.bind();
    program.enableAttributeArray(0);
    program.setAttributeBuffer(0, GL_FLOAT, 0, 2);

    textureCoordinatesBuffer.bind();
    program.enableAttributeArray(1);
    program.setAttributeBuffer(1, GL_FLOAT, 0, 2);

    program.setUniformValue(matrixLocation, pmvMatrix);
    program.setUniformValue(resolutionLocation, size);
    program.setUniformValue(timeLocation, time);
    program.setUniformValue(glitchScaleLocation, static_cast<float>(glitchScale));
    program.setUniformValue(percentLocation, static_cast<float>(percent));

    int counter = 0;
    QString str = "ranges[%1].%2";
    for (std::vector<ShiftRange>::iterator it = ranges.begin() ; it != ranges.end(); ++it) {
        ShiftRange range = *it;
        program.setUniformValue(qPrintable(str.arg(QString::number(counter), "start")), range.start);
        program.setUniformValue(qPrintable(str.arg(QString::number(counter), "length")), range.height);
        program.setUniformValue(qPrintable(str.arg(QString::number(counter), "direction")), range.direction);
        counter++;
    }

    program.setUniformValue(numRangesLocation, static_cast<int>(ranges.size()));
    program.setUniformValue(shiftAmountLocation, .25f);

    glBindTexture(GL_TEXTURE_2D, fbo.texture()); // provide sampler2D source
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindTexture(GL_TEXTURE_2D, 0);

    program.release();
    vertexPositionBuffer.release();
    textureCoordinatesBuffer.release();
}

std::vector<ShiftRange> GlitchPainter::generateRanges(int amount, double height) {
    std::vector<ShiftRange> ranges;
    GLfloat shiftYIndex = 0.;
    // Set Ranges
    for (float x = 0.; x < amount; x++) {
        shiftYIndex = shiftYIndex + static_cast<GLfloat>(QRandomGenerator::global()->bounded(height*.05));
        GLfloat shiftHeight = static_cast<GLfloat>(QRandomGenerator::global()->bounded(height*.15));
        ShiftRange range = {
            shiftYIndex,
            shiftHeight,
            std::fmod(x, 2.) == 0. ? -1.f : 1.f
        };
        shiftYIndex += shiftHeight + static_cast<GLfloat>(QRandomGenerator::global()->bounded(height*.1));
        ranges.push_back(range);
    }
    return ranges;
}

QImage GlitchPainter::paint(
  QImage &image,
  std::vector<ShiftRange> &ranges,
  qreal percent = .64,
  int time = 1000,
  qreal glitchScale = .5
) {
    QOpenGLFramebufferObject fbo(image.size(), fboFormat);
    fbo.bind();

    QOpenGLPaintDevice device(image.size());
    QPainter painter;
    painter.begin(&device);
    painter.setRenderHints(QPainter::Antialiasing | QPainter::HighQualityAntialiasing);

    painter.drawImage(image.rect(), image);

    painter.beginNativePainting();
    nativePainting(fbo, ranges, percent, time, glitchScale);
    painter.endNativePainting();

    painter.end();

    fbo.release();
    return fbo.toImage();
}
