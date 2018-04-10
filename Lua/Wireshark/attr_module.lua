
attr_module = {}

local attr_proto = Proto("attr", "Attr")

local VALS_BOOL =  {[0]="Not set",[1]="Set"}

local arr_attr_type = {
	[1]    = "TYPE_INTVALUE",
	[160]  = "TYPE_DISK_FILES",
	[1000] = "TYPE_NVR_V1",
}
-- syscp
local attr_type = ProtoField.uint16("attr.type", "Type", base.UNIT_STRING, arr_attr_type)
local attr_length = ProtoField.uint16("attr.len", "Length", base.DEC_HEX)

-- 将字段添加都协议中
attr_proto.fields = {
	attr_type,
	attr_length,
}

local data_dis = Dissector.get("data")

function attr_module.parse(tvb, pinfo, treeitem)
	local offset = 0
	
	local total_len = tvb:range(2, 2):uint()
	local attr_tree = treeitem:add(attr_proto, tvb:range(offset, total_len))
	attr_tree:add(attr_type, tvb:range(offset, 2))
	offset = offset + 2
	attr_tree:add(attr_length, tvb:range(offset, 2))
	offset = offset + 2	
	
	data_dis:call(tvb:range(offset, total_len-offset):tvb(), pinfo, treeitem)
	offset = total_len
	data_dis:call(tvb:range(offset):tvb(), pinfo, treeitem)

	return 
end
