#ifndef QBRUSHPROVIDER_H
#define QBRUSHPROVIDER_H

#include <QObject>
#include <QBrush>

class QBrushProvider : public QObject
{
  Q_OBJECT
public:
  explicit QBrushProvider(QObject *parent = nullptr);

  enum Brush {
    softSmall, softMedium, softLarge, softExtraLarge,
    hardSmall, hardMedium, hardLarge, hardExtraLarge,
    squareSmall, squareMedium, squareLarge, squareExtraLarge,
  };

  Q_ENUM(Brush)

  void setBrush(Brush brush);
  Brush brush() const;
  QBrush getQBrushForEnum() const;

private:
  Brush m_brush_type;
  QBrush m_qbrush;

signals:

public slots:
};

#endif // QBRUSHPROVIDER_H
