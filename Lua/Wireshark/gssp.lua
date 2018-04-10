----参考文档：
----https://www.wireshark.org/docs/wsdg_html_chunked/lua_module_Proto.html
require("login_module")
require("syscp_module")
require("media_control_module")
require("media_data_module")
require("download_module")

do
    --[[
        创建一个新的协议结构 gssp_proto
        第一个参数是协议名称会体现在过滤器中
        第二个参数是协议的描述信息，无关紧要
    --]]
    local gssp_proto = Proto("gssp", "GSSP Protocol")

    local VALS_BOOL =  {[0]="Not set",[1]="Set"}

	local arr_gssp_body_type = {
		[0x01]="Config",
		[0x11]="Log",
		[0x12]="Warning", 
		[0x13]="WarningEx", 
		[0x21]="Media Control", 
		[0x22]="Media Data", 
		[0x31]="Upgrade", 
		[0x41]="File Search", 
		[0x50]="Download", 
		[0x80]="Login",
	}
    --[[
        下面定义字段
    --]]
    local gssp_magic = ProtoField.string("gssp.magic", "Magic", base.ASCII)
	local gssp_flags = ProtoField.uint8("gssp.flags", "Flags", base.DEC_HEX)
    local gssp_flags_fpp = ProtoField.uint8("gssp.flags_fpp", "Data Complete", base.DEC_HEX, VALS_BOOL, 0x01)
    local gssp_flags_fcv = ProtoField.uint8("gssp.flags_fcv", "CheckSum Valid", base.DEC_HEX, VALS_BOOL, 0x02)
    local gssp_flags_fhb = ProtoField.uint8("gssp.flags_fhb", "HeartBeat", base.DEC_HEX, VALS_BOOL, 0x04)
    local gssp_flags_fre = ProtoField.uint8("gssp.flags_fre", "RESERVED", base.DEC_HEX, VALS_BOOL, 0x10)
    local gssp_flags_fenc = ProtoField.uint8("gssp.flags_fenc", "Encryption", base.DEC_HEX, VALS_BOOL, 0xe0)
    local gssp_version = ProtoField.uint8("gssp.version", "Version", base.DEC_HEX)
	local gssp_version_major = ProtoField.uint8("gssp.version_main", "Major Version", base.DEC_HEX, VALS_BOOL, 0x0f)
	local gssp_version_minor = ProtoField.uint8("gssp.version_minor", "Minor Version", base.DEC_HEX, VALS_BOOL, 0xf0)
    local gssp_sequence_num = ProtoField.uint16("gssp.sequence", "SequenceNumber", base.DEC)
	local gssp_session_id = ProtoField.uint16("gssp.sessionid", "Session ID", base.DEC)
	local gssp_head_len = ProtoField.uint8("gssp.headlen", "Head Length", base.DEC)
	local gssp_body_type = ProtoField.uint8("gssp.bodytype", "Body Type", base.HEX, arr_gssp_body_type)
	local gssp_body_len = ProtoField.uint16("gssp.bodylen", "Body Length", base.DEC)
	local gssp_check_sum = ProtoField.uint16("gssp.sessionid", "CheckSum", base.HEX)
	-- for test parameters
	local gssp_test = ProtoField.uint32("gssp.test", "Test", base.HEX)
	
   
    -- 将字段添加都协议中
    gssp_proto.fields = {
        gssp_magic,
        gssp_flags,	gssp_flags_fpp,	gssp_flags_fcv,	gssp_flags_fhb,	gssp_flags_fre,	gssp_flags_fenc,
		gssp_version, gssp_version_major, gssp_version_minor,
        gssp_sequence_num,
		gssp_session_id,
		gssp_head_len,
		gssp_body_type,
		gssp_body_len,
		gssp_check_sum,
		gssp_test,
    }

	local data_dis = Dissector.get("data")

	function gssp_proto.dissector(tvb, pinfo, treeitem)
		gssp_decode(tvb, pinfo, treeitem)
	end
	function gssp_decode(tvb, pinfo, treeitem)
		local offset = 0
		local magic = tvb:range(offset,4):string()
		if (magic ~= "GSSP")then
			data_dis:call(tvb, pinfo, treeitem)
			return
		end
        pinfo.cols.protocol:set("GMI_Protocol")
		
		-- 在上一级解析树上创建 gssp 的根节点
		local gssp_hdr_len = tvb:range(10,1):uint()
		local gssp_tree = treeitem:add(gssp_proto, tvb:range(offset, gssp_hdr_len))

		gssp_tree:add(gssp_magic, tvb:range(offset, 4))
		offset = offset+4
		
		local flags_tree = gssp_tree:add(gssp_flags, tvb:range(offset, 1))
		flags_tree:add(gssp_flags_fenc, tvb:range(offset, 1))
		flags_tree:add(gssp_flags_fre, tvb:range(offset, 1))
		flags_tree:add(gssp_flags_fhb, tvb:range(offset, 1))
		flags_tree:add(gssp_flags_fcv, tvb:range(offset, 1))
		flags_tree:add(gssp_flags_fpp, tvb:range(offset, 1))
		offset = offset + 1
		
		local version_tree = gssp_tree:add(gssp_version, tvb:range(offset, 1))
		version_tree:add(gssp_version_major, tvb:range(offset, 1))
		version_tree:add(gssp_version_minor, tvb:range(offset, 1))
		offset = offset + 1
		
		gssp_tree:add(gssp_sequence_num, tvb:range(offset, 2))
		offset = offset + 2
		gssp_tree:add(gssp_session_id, tvb:range(offset, 2))
		offset = offset + 2
		gssp_tree:add(gssp_head_len, tvb:range(offset, 1))
		offset = offset + 1
		local body_type = tvb:range(offset, 1):uint()
		gssp_tree:add(gssp_body_type, tvb:range(offset, 1))
		offset = offset + 1
		local body_len = tvb:range(offset, 4):uint()
		gssp_tree:add(gssp_body_len, tvb:range(offset, 4))
		offset = offset + 4
		gssp_tree:add(gssp_check_sum, tvb:range(offset, 4))
		offset = offset + 4
		local offset_tmp = offset
		
		-- 拼接多个tcp包
		if body_len > 0 then
			if body_len + offset < tvb:len() then
				--pinfo.cols.info:set("1");
			elseif body_len + offset > tvb:len() then
				--pinfo.cols.info:set("body_len:" .. body_len .. ", offset:" .. offset .. ", tvb:len():" .. tvb:len());
				pinfo.desegment_len = body_len+offset-tvb:len()
				pinfo.desegment_offset = 0
				return
			end
		elseif body_len == 0 then
			if body_type == 0x80 then
				pinfo.cols.info:set("<GSSP> <HeartBeat>")
			end
			return
		end

		-- 各个模块分别解析
		if (body_type == 0x01) then
			offset = offset + syscp_module.parse(tvb:range(offset, body_len):tvb(), pinfo, treeitem)
		elseif (body_type == 0x21) then
			offset = offset + media_control_module.parse(tvb:range(offset, body_len):tvb(), pinfo, treeitem)
		elseif (body_type == 0x22) then
			offset = offset + media_data_module.parse(tvb:range(offset, body_len):tvb(), pinfo, treeitem)
		elseif (body_type == 0x50) then
			offset = offset + download_module.parse(tvb:range(offset, body_len):tvb(), pinfo, treeitem)
		elseif (body_type == 0x80) then
			offset = offset + login_module.parse(tvb:range(offset, body_len):tvb(), pinfo, treeitem)
		end
		
		-- 检查是否在body_type_module中解析成功，如果有，这里会多出data字段出来
		data_dis:call(tvb:range(offset, offset_tmp+body_len-offset):tvb(), pinfo, treeitem)
		offset = offset_tmp + body_len
		
		-- 如果本包数据包含了超过一条数据内容的时候，需要不断的递归调用处理
		if (offset ~= tvb:len()) then
			pinfo.cols.protocol:set("offset:" .. offset .. " != tvb:len():" .. tvb:len() .. ", offset_tmp:" .. offset_tmp)
			gssp_decode(tvb:range(offset_tmp + body_len):tvb(), pinfo, treeitem)
		end
    end

    -- 向 wireshark 注册协议插件被调用的条件
    local tcp_port_table = DissectorTable.get("tcp.port")
    tcp_port_table:add(30000, gssp_proto)
end