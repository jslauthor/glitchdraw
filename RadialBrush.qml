import QtQuick 2.12
import QtGraphicalEffects 1.12

RadialGradient {
    gradient: Gradient {
        GradientStop { position: 0.0; color: "#FFFFFF" }
        GradientStop { position: Math.min(AppState.brush.hardness / 2, .49); color: "#FFFFFF" }
        GradientStop { position: 0.5; color: "#00000000" }
    }
}
