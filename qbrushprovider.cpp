#include "qbrushprovider.h"

QBrushProvider::QBrushProvider(QObject *parent) : QObject(parent)
{
  setBrush(Brush::softSmall);
}

void QBrushProvider::setBrush(Brush brush) {
  m_brush_type = brush;
  switch(brush) {
    case softSmall:
      break;
  }
}

QBrushProvider::Brush QBrushProvider::brush() const {
  return m_brush_type;
}

QBrush QBrushProvider::getQBrushForEnum() const {
  return m_qbrush;
}
