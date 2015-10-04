SECTIONS {
	.text: {
		*(.text)
		. = MAX(.,0x3FFC);
		*(.romcalls)
		. = MAX(.,0x7D60);
		*(.music)
	}
}
