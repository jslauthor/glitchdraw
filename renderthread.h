#ifndef RENDERTHREAD_H
#define RENDERTHREAD_H

#include <QThread>
#include <QImage>
#include <QMutex>
#include <QWaitCondition>
#include <led-matrix.h>
#include <QRgb>
#include <QDebug>

class RenderThread : public QThread
{
    Q_OBJECT

public:
    explicit RenderThread(QObject *parent = nullptr);
    ~RenderThread() override;

    Q_INVOKABLE void render(QImage &image);

protected:
    void run() Q_DECL_OVERRIDE;

private:
    QImage m_image;
    QMutex m_mutex;
    rgb_matrix::Canvas *m_canvas;
};

#endif // RENDERTHREAD_H
