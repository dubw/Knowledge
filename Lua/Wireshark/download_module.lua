
download_module = {}

local download_proto = Proto("download", "Download Data")

local VALS_BOOL =  {[0]="Not set",[1]="Set"}

local arr_download_type = {
	[0x00000001] = "DOWNLOAD_TYPE_RECORD_FILE_START_REQ",
	[0x00000002] = "DOWNLOAD_TYPE_RECORD_FILE_START_RSP",
	[0x00000003] = "DOWNLOAD_TYPE_RECORD_FILE_STOP_REQ",
	[0x00000004] = "DOWNLOAD_TYPE_RECORD_FILE_STOP_RSP",
	[0x00000005] = "DOWNLOAD_TYPE_RECORD_FRAME_START_REQ",
	[0x00000006] = "DOWNLOAD_TYPE_RECORD_FRAME_START_RSP",
	[0x00000007] = "DOWNLOAD_TYPE_RECORD_FRAME_STOP_REQ",
	[0x00000008] = "DOWNLOAD_TYPE_RECORD_FRAME_STOP_RSP",
	[0x00000009] = "DOWNLOAD_TYPE_RECORD_FILE_DATA",
}

-- download
local download_index = ProtoField.uint32("download.index", "Index", base.DEC_HEX)
local download_type = ProtoField.uint32("download.type", "Type", base.HEX, arr_download_type)
local download_filename = ProtoField.string("download.filename", "File Name", base.ASCII)
local download_reserved = ProtoField.bytes("download.reserved", "Reserved", base.NONE)
local download_result = ProtoField.bool("download.result", "Result", base.NONE, {"Failed","Success"})

-- download data
local download_lenght = ProtoField.uint32("download.lenght", "Lenght", base.DEC_HEX)
local download_filesize = ProtoField.uint32("download.filesize", "FileSize", base.DEC_HEX)
local download_offset = ProtoField.uint32("download.offset", "Offset", base.DEC_HEX)



-- 将字段添加都协议中
download_proto.fields = {
	download_index,
	download_type,
	download_filename,
	download_reserved,
	download_result,
	download_lenght,
	download_filesize,
	download_offset,
}

local data_dis = Dissector.get("data")

function download_file_data(tvb, pinfo, download_tree)
	local offset = 0
	
	download_tree:add(download_type, tvb:range(offset, 4))
	offset = offset + 4
	download_tree:add(download_lenght, tvb:range(offset, 4))
	offset = offset + 4
	download_tree:add(download_filesize, tvb:range(offset, 4))
	offset = offset + 4
	download_tree:add(download_offset, tvb:range(offset, 4))
	offset = offset + 4
	
	data_dis:call(tvb:range(offset, tvb:len()-offset):tvb(), pinfo, download_tree)
	offset = tvb:len()
	
	return offset
end

function download_file_req(tvb, pinfo, download_tree)
	local offset = 0
	
	download_tree:add(download_type, tvb:range(offset, 4))
	offset = offset + 4
	download_tree:add(download_index, tvb:range(offset, 4))
	offset = offset + 4
	download_tree:add(download_filename, tvb:range(offset, 128))
	offset = offset + 128
	download_tree:add(download_reserved, tvb:range(offset, 160))
	offset = offset + 160
	
	return offset
end

function download_file_rsp(tvb, pinfo, download_tree)
	local offset = 0
	
	download_tree:add(download_type, tvb:range(offset, 4))
	offset = offset + 4
	download_tree:add(download_result, tvb:range(offset, 4))
	offset = offset + 4
	
	return offset
end

function download_module.parse(tvb, pinfo, treeitem)
	local offset = 0
	
	local download_type = tvb:range(0,4):int()
	local download_tree
	if (download_type == 1) then
		download_tree = treeitem:add(download_proto, tvb:range(offset, 296))
		pinfo.cols.info:set("<GSSP> <Download> Download File Start Request")
		offset = offset + download_file_req(tvb:range(offset):tvb(), pinfo, download_tree)
	elseif (download_type == 2) then
		download_tree = treeitem:add(download_proto, tvb:range(offset, 8))
		pinfo.cols.info:set("<GSSP> <Download> Download File Start Reply")
		offset = offset + download_file_rsp(tvb:range(offset):tvb(), pinfo, download_tree)
	elseif (download_type == 3) then
		download_tree = treeitem:add(download_proto, tvb:range(offset, 296))
		pinfo.cols.info:set("<GSSP> <Download> Download File Stop Request")
		offset = offset + download_file_req(tvb:range(offset):tvb(), pinfo, download_tree)
	elseif (download_type == 4) then
		download_tree = treeitem:add(download_proto, tvb:range(offset, 8))
		pinfo.cols.info:set("<GSSP> <Download> Download File Stop Reply")
		offset = offset + download_file_rsp(tvb:range(offset):tvb(), pinfo, download_tree)
	elseif (download_type == 9) then
		local data_len = tvb:range(4,4):uint()
		download_tree = treeitem:add(download_proto, tvb:range(offset, 16 + data_len))
		pinfo.cols.info:set("<GSSP> <Download> Download File Data" .. data_len .. ":" .. tvb:range(offset):tvb():len())
		offset = offset + download_file_data(tvb:range(offset):tvb(), pinfo, download_tree)
	else
		pinfo.cols.info:set("don't know what is this")
	end

	data_dis:call(tvb:range(offset, tvb:len()-offset):tvb(), pinfo, treeitem)
	offset = tvb:len()
	
	return offset
end
