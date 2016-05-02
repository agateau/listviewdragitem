/*
 * listviewdragitem
 *
 * An example of reordering items in a ListView via drag'n'drop.
 *
 * Author: Aurélien Gâteau
 * License: BSD
 */
import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Window {
    visible: true
    width: 500
    height: 300

    ListModel {
        id: myModel
        ListElement {
            text: "The Phantom Menace"
        }
        ListElement {
            text: "Attack of the Clones"
        }
        ListElement {
            text: "Revenge of the Siths"
        }
        ListElement {
            text: "A New Hope"
        }
        ListElement {
            text: "The Empire Strikes Back"
        }
        ListElement {
            text: "Return of the Jedi"
        }
        ListElement {
            text: "The Force Awakens"
        }
    }

    Item {
        id: mainContent
        anchors.fill: parent
        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                color: "lightblue"
                height: 50
                Layout.fillWidth: true

                Text {
                    anchors.centerIn: parent
                    text: "A fake toolbar"
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ListView {
                    id: listView
                    model: myModel
                    delegate: DraggableItem {
                        Rectangle {
                            height: textLabel.height * 2
                            width: listView.width
                            color: "white"

                            Text {
                                id: textLabel
                                anchors.centerIn: parent
                                text: model.text
                            }

                            // Bottom line border
                            Rectangle {
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                height: 1
                                color: "lightgrey"
                            }
                        }

                        draggedItemParent: mainContent

                        onMoveItemRequested: {
                            myModel.move(from, to, 1);
                        }
                    }
                }
            }
        }
    }
}
