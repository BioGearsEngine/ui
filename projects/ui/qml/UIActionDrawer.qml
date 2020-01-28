import QtQuick 2.12
import QtQuick.Window 2.12

UIActionDrawerForm {
	id: root
	signal toggleState()

	onToggleState:{
		console.log(position)
		if (!root.opened){
			root.open();
		} else {
			root.close();
		}
	}
}
