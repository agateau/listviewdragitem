/*
 * listviewdragitem
 *
 * An example of reordering items in a ListView via drag'n'drop.
 *
 * Author: Aurélien Gâteau
 * License: BSD
 */
import QtQuick 2.0

Item {
    id: root

    default property Item contentItem

    // This item will become the parent of the dragged item during the drag operation
    property Item draggedItemParent

    signal moveItemRequested(int from, int to)

    // Size of the area at the top and bottom of the list where drag-scrolling happens
    property int scrollEdgeSize: 6

    // Internal: set to -1 when drag-scrolling up and 1 when drag-scrolling down
    property int _scrollingDirection: 0

    // Internal: shortcut to access the attached ListView from everywhere. Shorter than root.ListView.view
    property ListView _listView: ListView.view

    width: contentItem.width
    height: contentItem.height

    // Make contentItem a child of contentItemWrapper
    onContentItemChanged: {
        contentItem.parent = contentItemWrapper;
    }

    Rectangle {
        id: contentItemWrapper
        anchors.fill: parent
        Drag.active: dragArea.drag.active
        Drag.hotSpot {
            x: contentItem.width / 2
            y: contentItem.height / 2
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: parent
            // Keep the dragged item at the same X position. Nice for lists, but not mandatory
            drag.axis: Drag.YAxis
            // Disable smoothed so that the Item pixel from where we started the drag remains under the mouse cursor
            drag.smoothed: false

            onReleased: {
                if (drag.active) {
                    emitMoveItemRequested();
                }
            }
        }
    }

    SmoothedAnimation {
        id: upAnimation
        target: _listView
        property: "contentY"
        to: 0
        running: _scrollingDirection == -1
    }

    SmoothedAnimation {
        id: downAnimation
        target: _listView
        property: "contentY"
        to: _listView.contentHeight - _listView.height
        running: _scrollingDirection == 1
    }

    states: [
        State {
            when: dragArea.drag.active
            name: "dragging"

            ParentChange {
                target: contentItemWrapper
                parent: draggedItemParent
            }
            PropertyChanges {
                target: contentItemWrapper
                opacity: 0.9
                anchors.fill: undefined
                width: contentItem.width
                height: contentItem.height
            }
            PropertyChanges {
                target: root
                height: 0
                _scrollingDirection: {
                    var yCoord = _listView.mapFromItem(dragArea, 0, dragArea.mouseY).y;
                    if (yCoord < scrollEdgeSize) {
                        -1;
                    } else if (yCoord > _listView.height - scrollEdgeSize) {
                        1;
                    } else {
                        0;
                    }
                }
            }
        }
    ]

    Loader {
        id: topDropAreaLoader
        active: model.index === 0
        anchors {
            left: parent.left
            right: parent.right
            bottom: root.verticalCenter
        }
        height: contentItem.height
        sourceComponent: Component {
            DraggableItemDropArea {
                dropIndex: 0
            }
        }
    }

    DraggableItemDropArea {
        anchors {
            left: parent.left
            right: parent.right
            top: root.verticalCenter
        }
        height: contentItem.height
        dropIndex: model.index + 1
    }

    function emitMoveItemRequested() {
        var dropArea = contentItemWrapper.Drag.target;
        if (!dropArea) {
            return;
        }
        var dropIndex = dropArea.dropIndex;

        // If the target item is below us, then decrement dropIndex because the target item is going to move up when
        // our item leaves its place
        if (model.index < dropIndex) {
            dropIndex--;
        }
        if (model.index === dropIndex) {
            return;
        }
        root.moveItemRequested(model.index, dropIndex);

        // Scroll the ListView to ensure the dropped item is visible. This is required when dropping an item after the
        // last item of the view. Delay the scroll using a Timer because we have to wait until the view has moved the
        // item before we can scroll to it.
        makeDroppedItemVisibleTimer.start();
    }

    Timer {
        id: makeDroppedItemVisibleTimer
        interval: 0
        onTriggered: {
            _listView.positionViewAtIndex(model.index, ListView.Contain);
        }
    }
}
