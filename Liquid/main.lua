dofile(getScriptPath().."\\dataStorage.lua")
dofile(getScriptPath().."\\dll_Robot.lua")


is_run = true
Timer = 3
FileLog = getScriptPath().."\\BOT1_LOG.txt"
FileData = getScriptPath().."\\BOT1_DATA.txt"
Problem = ""

-----------------------------------
Class = "TQBR"

Columns = {
	_Ticker = 1,
	_1D_Change = 2,
	_10M_Change = 3,
	_5M_Change = 4,
	_3M_Change = 5,
	_1M_Change = 6
}

EmitentsSize = 35

function OnInit()
	TableID = AllocTable() 
	AddColumn(TableID, Columns._Ticker, "Тикер", true, QTABLE_STRING_TYPE, 15)
	AddColumn(TableID, Columns._1D_Change, "|%1d|", true, QTABLE_STRING_TYPE, 10)
	AddColumn(TableID, Columns._10M_Change, "|%10m|", true, QTABLE_STRING_TYPE, 10)
	AddColumn(TableID, Columns._5M_Change, "|%5m|", true, QTABLE_STRING_TYPE, 10)
	AddColumn(TableID, Columns._3M_Change, "|%3m|", true, QTABLE_STRING_TYPE, 10)
	AddColumn(TableID, Columns._1M_Change, "|%1m|", true, QTABLE_STRING_TYPE, 10)

		
	CreateWindow(TableID)
	-- EmitentsInitialization()
	PutDataToTableInit()

	WriteToEndOfFile(FileLog, "Скринер запущен")
end

function main()
	while is_run == true do
		Body()
	end
end


function OnStop()
	is_run = false
	DestroyTable(TableID)
	WriteToEndOfFile(FileLog, "Скринер остановлен­")
end


