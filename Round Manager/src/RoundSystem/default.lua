--@class default.lua
--# Default States

return table.freeze({
	[1]={
		Name='Intermission';
		Timer=5;
	};
	[2]={
		Name='Round';
		Timer=15;
	};
	[3]={
		Name='Summary';
		Timer=5;
	};
})