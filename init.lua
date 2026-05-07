--!nocheck
shared.catdata = {Key = script_key or 'none'}
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local downloader = Instance.new('TextLabel')
downloader.Size = UDim2.new(1, 0, 0, 40)
downloader.BackgroundTransparency = 1
downloader.TextStrokeTransparency = 0
downloader.TextSize = 20
downloader.TextColor3 = Color3.new(1, 1, 1)
downloader.Font = Enum.Font.Arial
downloader.Text = ''
downloader.Parent = Instance.new('ScreenGui', gethui and gethui() or game:GetService('CoreGui'))

local function downloadFile(path, func)
	if not isfile(path) then
		downloader.Text = 'Downloading '.. path
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/ppsnip/Catvape-mine/'..readfile('catvape_ppsnip/profiles/commit.txt')..'/'..select(1, path:gsub('catvape_ppsnip/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after updates.\n'..res
		end
		writefile(path, res)
		downloader.Text = ''
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('init') then continue end
		if file:find('profile') then continue end
		if isfile(file) then
			delfile(file)
		elseif isfolder(file) then
			wipeFolder(file)
		end
	end
end

for _, folder in {'catvape_ppsnip', 'catvape_ppsnip/games', 'catvape_ppsnip/profiles', 'catvape_ppsnip/assets', 'catvape_ppsnip/libraries', 'catvape_ppsnip/guis'} do
	if not isfolder(folder) then
		downloader.Text = 'Creating '.. folder
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local _, subbed = pcall(function()
		return game:HttpGet('https://github.com/ppsnip/Catvape-mine')
	end)
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('catvape_ppsnip/profiles/commit.txt') and readfile('catvape_ppsnip/profiles/commit.txt') or '') ~= commit then
		if commit ~= 'main' and isfile('catvape_ppsnip/profiles/commit.txt') then
			shared.updated = readfile('catvape_ppsnip/profiles/commit.txt')
		end
		wipeFolder('catvape_ppsnip')
		wipeFolder('catvape_ppsnip/games')
		wipeFolder('catvape_ppsnip/guis')
		wipeFolder('catvape_ppsnip/libraries')
	end
	writefile('catvape_ppsnip/profiles/commit.txt', commit)
end

downloader.Text = ''
return loadstring(downloadFile('catvape_ppsnip/main.lua'), 'main')()
