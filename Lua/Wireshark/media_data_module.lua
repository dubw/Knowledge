
media_data_module = {}

local media_data_proto = Proto("media_data", "Media Data")

local VALS_BOOL =  {[0]="Not set",[1]="Set"}

local arr_media_control_type = {
	----gmi/elec_sdk/base/protocol/media_control_session
	[0x00000005] = "Private Stream",
}
local arr_media_data_encode_type = {
	[0] = "None",
	[1] = "H.264",
	[2] = "MJPEG",
}

-- media_data
local media_data_type = ProtoField.uint32("media_data.type", "Type", base.HEX, arr_media_control_type)
local media_data_frame_type = ProtoField.string("media_data.frame_type", "Frame Type", base.ASCII)
local media_data_streamid = ProtoField.uint8("media_data.streamid", "Stream ID", base.DEC)
local media_data_frameid = ProtoField.uint32("media_data.frameid", "Frame ID", base.DEC)
local media_data_pts = ProtoField.uint64("media_data.pts", "PTS", base.DEC)
-- media data I frame
local media_data_I_rate = ProtoField.uint8("media_data.rate", "Rate", base.DEC)
local media_data_I_encode_type = ProtoField.uint8("media_data.encode_type", "Encode Type", base.HEX, arr_media_data_encode_type)
local media_data_I_idr = ProtoField.uint8("media_data.idr", "I Frame Interval", base.DEC)
local media_data_I_reserved = ProtoField.uint24("media_data.reserved", "Reserved", base.HEX)
local media_data_I_width = ProtoField.uint16("media_data.width", "Width", base.DEC)
local media_data_I_height = ProtoField.uint16("media_data.height", "Height", base.DEC)
-- media data P,B frame
local media_data_PB_reserved = ProtoField.uint24("media_data.pb_reserved", "Reserved", base.HEX)

-- for test parameters
local media_data_test = ProtoField.uint32("media_data.test", "Test", base.HEX)

-- 将字段添加都协议中
media_data_proto.fields = {
	media_data_type,
	media_data_frame_type,
	media_data_streamid,
	media_data_I_rate,
	media_data_I_encode_type,
	media_data_I_idr,
	media_data_I_reserved,
	media_data_pts,
	media_data_frameid,
	media_data_I_width,
	media_data_I_height,
	media_data_PB_reserved,
}

local data_dis = Dissector.get("data")

function media_data_video_I(tvb, pinfo, media_data_tree)
	local offset = 0
	media_data_tree:add(media_data_type, tvb:range(offset, 4))
	offset = offset + 4
	media_data_tree:add(media_data_frame_type, tvb:range(offset, 1))
	offset = offset + 1
	media_data_tree:add(media_data_streamid, tvb:range(offset, 1))
	offset = offset + 1
	media_data_tree:add(media_data_I_rate, tvb:range(offset, 1))
	offset = offset + 1
	media_data_tree:add(media_data_I_encode_type, tvb:range(offset, 1))
	offset = offset + 1
	media_data_tree:add(media_data_I_idr, tvb:range(offset, 1))
	offset = offset + 1
	media_data_tree:add(media_data_I_reserved, tvb:range(offset, 3))
	offset = offset + 3
	media_data_tree:add(media_data_pts, tvb:range(offset, 8))
	offset = offset + 8
	media_data_tree:add(media_data_frameid, tvb:range(offset, 4))
	offset = offset + 4
	media_data_tree:add(media_data_I_width, tvb:range(offset, 2))
	offset = offset + 2
	media_data_tree:add(media_data_I_height, tvb:range(offset, 2))
	offset = offset + 2

	return offset
end
function media_data_video_PB(tvb, pinfo, media_data_tree)
	local offset = 0
	media_data_tree:add(media_data_type, tvb:range(offset, 4))
	offset = offset + 4
	media_data_tree:add(media_data_frame_type, tvb:range(offset, 1))
	offset = offset + 1
	media_data_tree:add(media_data_streamid, tvb:range(offset, 1))
	offset = offset + 1
	media_data_tree:add(media_data_PB_reserved, tvb:range(offset, 2))
	offset = offset + 2
	media_data_tree:add(media_data_frameid, tvb:range(offset, 4))
	offset = offset + 4
	media_data_tree:add(media_data_pts, tvb:range(offset, 8))
	offset = offset + 8

	return offset
end

function media_data_module.parse(tvb, pinfo, treeitem)
	local offset = 0
	
	local media_data_frame_type = tvb:range(4,1):string()
	local media_data_tree
	if (media_data_frame_type == 'I') then
		media_data_tree = treeitem:add(media_data_proto, tvb:range(offset, 28))
		pinfo.cols.info:set("I Frame")
		offset = offset + media_data_video_I(tvb:range(offset):tvb(), pinfo, media_data_tree)
	elseif (media_data_frame_type == 'P') then
		media_data_tree = treeitem:add(media_data_proto, tvb:range(offset, 20))
		pinfo.cols.info:set("P/B Frame")
		offset = offset + media_data_video_PB(tvb:range(offset):tvb(), pinfo, media_data_tree)
	else
		pinfo.cols.info:set("Media Data, not P or I Frame")
	end

	data_dis:call(tvb:range(offset, tvb:len()-offset):tvb(), pinfo, treeitem)
	offset = tvb:len()
	
	return offset
end
