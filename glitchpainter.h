#ifndef GLITCHPAINTER_H
#define GLITCHPAINTER_H

#include <QtCore>
#include <QtGui>
#include <QObject>
#include <QImage>
#include <QOpenGLFunctions>
#include <QDebug>

class GlitchPainter : public QObject, protected QOpenGLFunctions
{
    Q_OBJECT
public:
    explicit GlitchPainter(QObject *parent = nullptr);

    QImage paint(
        QImage &image,
        qreal percent,
        int time,
        qreal glitchScale
    );
    void nativePainting(
        QOpenGLFramebufferObject &fbo,
        qreal percent,
        int time,
        qreal glitchScale
    );

signals:

public slots:

private:
    QSurfaceFormat format;
    QOffscreenSurface surface;
    QOpenGLContext context;
    QOpenGLFramebufferObjectFormat fboFormat;

    QOpenGLShaderProgram program;
    int matrixLocation;
    int resolutionLocation;
    int timeLocation;
    int glitchScaleLocation;
    int percentLocation;
};

#endif // GLITCHPAINTER_H
