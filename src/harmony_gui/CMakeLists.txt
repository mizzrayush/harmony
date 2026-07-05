# Harmony GUI source files and resources configuration

SET(CMAKE_AUTORCC ON)
SET(CMAKE_AUTOMOC ON)

SET(HARMONY_GUI_SRCS
	${HARMONY_GUI_SRCS}
	harmony_gui/HarmonyApp.cpp
	harmony_gui/harmony_qml.qrc
	PARENT_SCOPE
)
