prevSecValue = 0
prevMinValue = 0
prevHourValue = 0

currentSecValue = 0
currentMinValue = 0
currentHourValue = 0

currentTime = 0

-- Менять при компиляции --
local IS_LUQID_ROBOT = true
-----------------------------

------Максимальные периуды--------
local MAX_1M_PERIOD_SIZE = 6 -- 6 секунд по 10 секунд за тик
local MAX_3M_PERIOD_SIZE = 6 -- 30 секунд по 6 секунд за тик
local MAX_5M_PERIOD_SIZE = 5 -- 5 периудов по 1 минуте
local MAX_10M_PERIOD_SIZE = 10 -- 10 минут по 1 минутке за тик
--##############################-

local function getCurrentPrice(ticker_id)
	local price = string.format("%g",string.format("%.2f", tostring(math.abs(getParamEx(Class, Emitents[ticker_id][Columns._Ticker], "LASTCHANGE").param_value))))

	return price
end

local function addElementToList(src, v, perioudSize)
    if (#src == perioudSize) then
        table.remove(src, 1)
    end
    

    table.insert(src, v)

end

function Body() -- Основные вычисления
	currentTime = getInfoParam("SERVERTIME")
	currentHourValue, currentMinValue, currentSecValue = currentTime:match("(%d+):(%d+):(%d+)")

	if (Timer > 0) then
		Timer = Timer - 1
		PutDataToTableTimer()
		sleep(1000)
		return
	end


	local ServerTime = getInfoParam("SERVERTIME")
	if (ServerTime == nil or ServerTime == "") then
		Problem = "Server time not received!"
		Timer = 3
		return 
	else
		Problem = ""
	end

	if (IsWindowClosed(TableID)) then
		CreateWindow(TableID)
		PutDataToTableInit()
	end

		-- Callback update
		if currentHourValue ~= prevHourValue then
			OnOneHourUpdate(currentHourValue)
			prevHourValue = currentHourValue
		end
	
		if currentMinValue ~= prevMinValue then
			OnOneMinUpdate(currentMinValue)
			prevMinValue = currentMinValue
		end
	
		OnOneSecUpdate(currentSecValue)
		prevSecValue = currentSecValue
	
		updateAllCells()
		-- updateStartPosition()

	-- Колоризация отдельных строк с интересными ситуациями
	if IS_LUQID_ROBOT == true then
		for i = 1, #Emitents do
			local _1mValue = tonumber(GetCell(TableID, i, Columns._1M_Change).image)
			local _3mValue = tonumber(GetCell(TableID, i, Columns._3M_Change).image)

			if (_1mValue >= 0.50) then
				if (_3mValue >= 0.50) then
					-- мигался красным
					Highlight(TableID, i,  QTABLE_NO_INDEX, RGB(255, 0, 0), RGB(255, 255, 255), 5000)
					return 0
				end
				-- мигалка зелёным
				Highlight(TableID, i,  QTABLE_NO_INDEX, RGB(76, 153, 0), RGB(255, 255, 255), 5000)
			elseif (_1mValue >= 0.30) then
				-- мигалка жёлтым
				Highlight(TableID, i,  QTABLE_NO_INDEX, RGB(102, 102, 0), RGB(255, 255, 255), 5000)
			end

			
		end
	end
	sleep(1000)
end

-- Callbacks
function OnOneHourUpdate(dHour)
	-- срабатывает каждый час

end

function OnOneMinUpdate(dMin)
	-- срабатывает каждую минуту
	
	-- 5M
	for i = 1, #Emitents do
		addElementToList(Emitents[i][Columns._5M_Change], getCurrentPrice(i), MAX_5M_PERIOD_SIZE)
		addElementToList(Emitents[i][Columns._10M_Change], getCurrentPrice(i), MAX_10M_PERIOD_SIZE)
	end

end

function OnOneSecUpdate(dSec)
	-- срабатывает каждую секунду

	-- 1M
	if (dSec % 10) == 0 then
		for i = 1, #Emitents do
			addElementToList(Emitents[i][Columns._1M_Change], getCurrentPrice(i), MAX_1M_PERIOD_SIZE)
		end
	end

	-- 3M
	if (dSec % 30) == 0 then
		for i = 1, #Emitents do
			addElementToList(Emitents[i][Columns._3M_Change], getCurrentPrice(i), MAX_3M_PERIOD_SIZE)
		end
	end
end


function updateAllCells()
	for i = 1, #Emitents do
		local price = getCurrentPrice(i)
		Emitents[i][2] = getCurrentPrice(i)
		SetCell(TableID, i, 2, Emitents[i][2])

		for j = 3, #Emitents[i] do
			SetCell(TableID, i, j, tostring(math.abs(math.abs(tonumber(price)) - math.abs(tonumber(Emitents[i][j][1])))) )
		end
	end
end

function PutDataToTableTimer()
	SetCell(TableID, 1, 3, Problem)
	Highlight(TableID, 1,  QTABLE_NO_INDEX, RGB(0, 20, 255), RGB(255, 255, 255), 500)
end

-- Инициализация таблицы при первом запуске
function EmitentsInitialization()
		for i = 1, #Emitents do
				Emitents[i][1] = getCurrentPrice(i)
				for j = 2, #Emitents[i] do
					table.insert(Emitents[i][j], getCurrentPrice(i))
				end
		end
end

--------------Получение данных из таблицы текущих инструментов-------------------
function getDataFromEmitTable()
	for i = 1, EmitentsSize do
		local lastchange = string.format("%g",string.format("%.2f", tostring(getParamEx(Class, Emitents[i][Columns._Ticker], "LASTCHANGE").param_value))) -- param_value для чисел
		-- SetCell(TableID, i, Columns._1D_Change, lastchange)
		SetCell(TableID, i, Columns._1M_Change, tostring(math.abs(math.abs(tonumber(lastchange)) - math.abs(tonumber(Emitents[i][Columns._1M_Change])))) )
	end
end

function PutDataToTableInit()
	--Clear(TableID)
	SetWindowPos(TableID, 100, 200, 500, 300)
	SetWindowCaption(TableID, "Quik 8.7.1.3 | Liquid stock screener by VLASSAL")

	----------------------[Инициализация инструментов]---------------
	for i = 1, #Emitents do
		InsertRow(TableID, -1)
		SetCell(TableID, i, Columns._Ticker, Emitents[i][Columns._Ticker])
		Emitents[i][2] = getCurrentPrice(i)
		for j = 3, #Emitents[i] do
			table.insert(Emitents[i][j], getCurrentPrice(i))
		end
	end
end

function WriteToEndOfFile(sFile, sDataString)
	local serverTime = getInfoParam("SERVERTIME")
	local serverData = getInfoParam("TRADEDATE")
	sDataString = serverData..";"..serverTime..";"..sDataString.."\n"
	local f = io.open(sFile, "r+")
	if (f == nil) then
		f = io.open(sFile, "w")
	end
	if (f ~= nil) then
		f:seek("end", 0) -- устанавливает в определенном месте файла курсор
		f:write(sDataString)
		f:flush() -- сохранение
		f:close()
	end
end
