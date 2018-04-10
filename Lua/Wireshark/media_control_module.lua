
media_control_module = {}

local media_control_proto = Proto("media_control", "Media Control")

local VALS_BOOL =  {[0]="Not set",[1]="Set"}

local arr_media_control_type = {
	----gmi/elec_sdk/base/protocol/media_control_session
	[0x00000001] = "Open Video Audio Request",
	[0x00000002] = "Open Video Audio Response",
	[0x00000007] = "Close Video Audio Request",
	[0x00000009] = "Open Audio Talk Request",
	[0x0000000b] = "Close Audio Talk Request",
}

local arr_media_control_trans_type = {
	[0] = "UDP",
	[1] = "TCP",
}

-- media_control
local media_control_type = ProtoField.uint32("media_control.type", "Type", base.UNIT_STRING, arr_media_control_type)
local media_control_result = ProtoField.bool("media_control.result", "Result", base.NONE, {"Failed","Success"});
-- media open video audio request
local media_control_streamid = ProtoField.uint16("media_control.streamid", "Stream ID", base.DEC_HEX)
local media_control_streamid1 = ProtoField.uint16("media_control.streamid1", "Stream1", base.DEC_HEX, VALS_BOOL, 0x01)
local media_control_streamid2 = ProtoField.uint16("media_control.streamid2", "Stream2", base.DEC_HEX, VALS_BOOL, 0x02)
local media_control_streamid3 = ProtoField.uint16("media_control.streamid3", "Stream3", base.DEC_HEX, VALS_BOOL, 0x04)
local media_control_streamid4 = ProtoField.uint16("media_control.streamid4", "Stream4", base.DEC_HEX, VALS_BOOL, 0x08)
local media_control_trans_type = ProtoField.uint8("media_control.trans_type", "Transport Protocol", base.UNIT_STRING, arr_media_control_trans_type)
local media_control_reserved = ProtoField.uint8("media_control.reserved", "Reserved", base.HEX)
local media_control_destination_ip = ProtoField.string("media_control.destination_ip", "Destination IP", base.ASCII)
local media_control_destination_port = ProtoField.uint32("media_control.destination_port", "Destination Port", base.DEC)
-- media open video audio response
local media_control_openav_rsp_number = ProtoField.uint8("media_control.openav_rsp_number", "Number", base.DEC)
local media_control_openav_rsp_iResult = ProtoField.int32("media_control.openav_rsp_result", "Result", base.DEC)
local media_control_openav_rsp_streamid = ProtoField.uint8("media_control.openav_rsp_streamid", "Stream ID", base.DEC)
local media_control_openav_rsp_rate = ProtoField.uint8("media_control.openav_rsp_rate", "Rate", base.DEC)
local media_control_openav_rsp_idr = ProtoField.uint8("media_control.openav_rsp_idr", "I Frame Interval", base.DEC)
local media_control_openav_rsp_encode = ProtoField.uint8("media_control.openav_rsp_encode", "Encode Type", base.DEC, {[1]="H.264",[2]="MJPEG"})
local media_control_openav_rsp_width = ProtoField.uint16("media_control.openav_rsp_width", "Width", base.DEC)
local media_control_openav_rsp_height = ProtoField.uint16("media_control.openav_rsp_height", "Height", base.DEC)

--

-- for test parameters
local media_control_test = ProtoField.uint32("media_control.test", "Test", base.HEX)

-- 将字段添加都协议中
media_control_proto.fields = {
	media_control_type,
	media_control_result,
	media_control_streamid,media_control_streamid1,media_control_streamid2,media_control_streamid3,media_control_streamid4,
	media_control_trans_type,
	media_control_reserved,
	media_control_destination_ip,
	media_control_destination_port,
	media_control_openav_rsp_number,
	media_control_openav_rsp_iResult,
	media_control_openav_rsp_streamid,
	media_control_openav_rsp_rate,
	media_control_openav_rsp_idr,
	media_control_openav_rsp_encode,
	media_control_openav_rsp_width,
	media_control_openav_rsp_height,
}

local data_dis = Dissector.get("data")

function media_control_open_av_req(tvb, pinfo, media_control_tree)
	local offset = 0
	media_control_tree:add(media_control_type, tvb:range(offset, 4))
	offset = offset + 4
	local stream_tree = media_control_tree:add(media_control_streamid, tvb:range(offset, 2))
	stream_tree:add(media_control_streamid1, tvb:range(offset, 2))
	stream_tree:add(media_control_streamid2, tvb:range(offset, 2))
	stream_tree:add(media_control_streamid3, tvb:range(offset, 2))
	stream_tree:add(media_control_streamid4, tvb:range(offset, 2))
	offset = offset + 2
	media_control_tree:add(media_control_trans_type, tvb:range(offset, 1))
	offset = offset + 1
	media_control_tree:add(media_control_reserved, tvb:range(offset, 1))
	offset = offset + 1
	media_control_tree:add(media_control_destination_ip, tvb:range(offset, 32))
	offset = offset + 32
	media_control_tree:add(media_control_destination_port, tvb:range(offset, 4))
	offset = offset + 4

	return offset
end
function media_control_open_av_rsp(tvb, pinfo, media_control_tree)
	local offset = 0
	media_control_tree:add(media_control_type, tvb:range(offset, 4))
	offset = offset + 4
	media_control_tree:add(media_control_result, tvb:range(offset, 4))
	offset = offset + 4
	media_control_tree:add(media_control_openav_rsp_number, tvb:range(offset, 4))
	offset = offset + 4
	media_control_tree:add(media_control_openav_rsp_iResult, tvb:range(offset, 4))
	offset = offset + 4
	media_control_tree:add(media_control_openav_rsp_streamid, tvb:range(offset, 1))
	offset = offset + 1
	media_control_tree:add(media_control_openav_rsp_rate, tvb:range(offset, 1))
	offset = offset + 1
	media_control_tree:add(media_control_openav_rsp_idr, tvb:range(offset, 1))
	offset = offset + 1
	media_control_tree:add(media_control_openav_rsp_encode, tvb:range(offset, 1))
	offset = offset + 1
	media_control_tree:add(media_control_openav_rsp_width, tvb:range(offset, 2))
	offset = offset + 2
	media_control_tree:add(media_control_openav_rsp_height, tvb:range(offset, 2))
	offset = offset + 2

	return offset
end

function media_control_module.parse(tvb, pinfo, treeitem)
	local offset = 0
	
	local media_control_tree = treeitem:add(media_control_proto, tvb:range(offset))
	local media_control_type = tvb:range(offset, 4):uint()
	if (media_control_type == 0x00000001) then
		offset = media_control_open_av_req(tvb, pinfo, media_control_tree)
	elseif (media_control_type == 0x00000002) then
		offset = media_control_open_av_rsp(tvb, pinfo, media_control_tree)
	end
	
	return offset
end
