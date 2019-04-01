#ifndef GLITCHPAINTER_H
#define GLITCHPAINTER_H

#include <QtCore>
#include <QtGui>
#include <QObject>
#include <QImage>
#include <QOpenGLFunctions>
#include <QDebug>

struct ShiftRange {
    GLfloat start;
    GLfloat height;
    GLfloat direction;
};

class GlitchPainter : public QObject, protected QOpenGLFunctions
{
    Q_OBJECT
public:
    explicit GlitchPainter(QObject *parent = nullptr);

    QImage paint(
        QImage &image,
        std::vector<ShiftRange> &ranges,
        qreal percent,
        int time,
        qreal glitchScale
    );
    void nativePainting(
        QOpenGLFramebufferObject &fbo,
        std::vector<ShiftRange> &ranges,
        qreal percent,
        int time,
        qreal glitchScale
    );

    std::vector<ShiftRange> generateRanges(int amount, double height);

signals:

public slots:

private:
    QSurfaceFormat format;
    QOffscreenSurface surface;
    QOpenGLContext context;
    QOpenGLFramebufferObjectFormat fboFormat;
    std::vector<ShiftRange> ranges;
};

#endif // GLITCHPAINTER_H
