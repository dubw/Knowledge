require("attr_module")

syscp_module = {}

local syscp_proto = Proto("syscp", "Syscp")

local VALS_BOOL =  {[0]="Not set",[1]="Set"}

local arr_syscp_type = {
	----gmi/elec_sdk/base/protocol/syscp_session
	[1011] = "SYSCODE_SET_IPINFO_REQ",
	[1013] = "SYSCODE_GET_IPINFO_REQ",
	[1021] = "SYSCODE_SET_USERINFO_REQ",
	[1023] = "SYSCODE_GET_USERINFO_REQ",
	[1025] = "SYSCODE_DEL_USERINFO_REQ",
	[1031] = "SYSCODE_SET_ENCODECFG_REQ",
	[1033] = "SYSCODE_GET_ENCODECFG_REQ",
	[1041] = "SYSCODE_SET_SHOWCFG_REQ",
	[1043] = "SYSCODE_GET_SHOWCFG_REQ",
	[1051] = "SYSCODE_SET_SYSCFG_REQ",
	[1053] = "SYSCODE_GET_SYSCFG_REQ",
	[1061] = "SYSCODE_SET_TIME_REQ",
	[1063] = "SYSCODE_GET_TIME_REQ",
	[1071] = "SYSCODE_3DPTZ_CTL_REQ",
	[1073] = "SYSCODE_SET_PTZHOME_REQ",
	[1075] = "SYSCODE_GET_PTZHOME_REQ",
	[1077] = "SYSCODE_CTL_PTZ_REQ",
	[1081] = "SYSCODE_SET_PTZPRESET_REQ",
	[1083] = "SYSCODE_GET_PTZPRESET_REQ",
	[1087] = "SYSCODE_SET_PTZ_DECODER_REQ",
	[1089] = "SYSCODE_GET_PTZ_DECODER_REQ",
	[1091] = "SYSCODE_CTL_SYSTEM_REQ",
	[1101] = "SYSCODE_FIND_STORAGEFILE_REQ",
	[1103] = "SYSCODE_GET_STORAGEFILE_REQ",
	[1121] = "SYSCODE_SET_HIDEAREA_REQ",
	[1123] = "SYSCODE_GET_HIDEAREA_REQ",
	[1131] = "SYSCODE_GET_PERFORMANCE_REQ",
	[1141] = "SYSCODE_SET_ALMDEPLOY_REQ",
	[1143] = "SYSCODE_GET_ALMDEPLOY_REQ",
	[1151] = "SYSCODE_SET_ALMCFG_REQ",
	[1153] = "SYSCODE_GET_ALMCFG_REQ",
	[1161] = "SYSCODE_EXTERNAL_CTRL_REQ",
	[1171] = "SYSCODE_GET_IMAGING_REQ",
	[1173] = "SYSCODE_SET_IMAGING_REQ",
	[1175] = "SYSCODE_GET_VIDEO_SOURCE_INFO_REQ",
	[1177] = "SYSCODE_GET_ADVANCED_IMAGING_REQ",
	[1179] = "SYSCODE_SET_ADVANCED_IMAGING_REQ",
	[1181] = "SYSCODE_FORCE_IDR_REQ",
	[1191] = "SYSCODE_GET_DEVICE_WORK_STATE_REQ",
	[1193] = "SYSCODE_GET_NETWORK_PORT_REQ",
	[1195] = "SYSCODE_SET_NETWORK_PORT_REQ",
	[1197] = "SYSCODE_GET_CAPABILITIES_REQ",
	[1201] = "SYSCODE_GET_ENCSTREAM_COMBINE_REQ",
	[1203] = "SYSCODE_SET_ENCSTREAM_COMBINE_REQ",
	[1205] = "SYSCODE_GET_AUDIO_ENCODE_REQ",
	[1207] = "SYSCODE_SET_AUDIO_ENCODE_REQ",
	[1210] = "SYSCODE_START_VOICECOM_REQ",
	[1212] = "SYSCODE_STOP_VOICECOM_REQ",
	[1215] = "SYSCODE_GET_WHITEBALANCE_REQ",
	[1217] = "SYSCODE_SET_WHITEBALANCE_REQ",
	[1223] = "SYSCODE_GET_DAY_NIGHT_REQ",
	[1225] = "SYSCODE_SET_DAY_NIGHT_REQ",
	[1227] = "SYSCODE_GET_LOGINFO_REQ",
	[1229] = "SYSCODE_GET_ALARM_REQ",
	[1230] = "SYSCODE_GET_ALARM_RSP",
	[1235] = "SYSCODE_GET_PTZ_POSITION_REQ",
	[1237] = "SYSCODE_SET_PTZ_POSITION_REQ",
	[1239] = "SYSCODE_GET_PTZ_CRUISE_REQ",
	[1241] = "SYSCODE_SET_PTZ_CRUISE_REQ",
	[1243] = "SYSCODE_DEL_PTZ_CRUISE_REQ",
	[1245] = "SYSCODE_GET_SHIELD_VERSION_REQ",
	[1211] = "SYSCODE_GET_AUTOFOCUS_REQ",
	[1213] = "SYSCODE_SET_AUTOFOCUS_REQ",
	[1247] = "SYSCODE_GET_ZOOM_RANGE_REQ",
	[1249] = "SYSCODE_SET_ZOOM_RANGE_REQ",
	[1251] = "SYSCODE_CTL_PTZ_GET_REQ",
	[1253] = "SYSCODE_SET_CAMERA_CONTROL_REQ",
	[1255] = "SYSCODE_GET_CAMERA_CONTROL_REQ",
	[1257] = "SYSCODE_GET_RECORD_INFO_REQ",
	[1259] = "SYSCODE_SET_RECORD_INFO_REQ",
	[1261] = "SYSCODE_GET_RECORD_DEPLOY_REQ",
	[1263] = "SYSCODE_SET_RECORD_DEPLOY_REQ",
	[1265] = "SYSCODE_SET_RECORD_FORMAT_REQ",
	[1267] = "SYSCODE_GET_RECORD_MEDIA_REQ",
	[1269] = "SYSCODE_GET_RECORD_FILE_REQ",
	[1275] = "SYSCODE_SET_ALARM_CENTER_CFG_REQ",
	[1277] = "SYSCODE_GET_ALARM_CENTER_CFG_REQ",
	[1299] = "SYSCODE_SET_ALARM_SMART_REQ",
	[1301] = "SYSCODE_GET_ALARM_SMART_REQ",
	[1303] = "SYSCODE_SET_ALARM_ENV_REQ",
	[1305] = "SYSCODE_GET_ALARM_ENV_REQ",
	[1307] = "SYSCODE_SET_PLATE_CTRL_REQ",
	[1308] = "SYSCODE_GET_ALARM_DISK_RSP",
	[1317] = "SYSCODE_TRANS_COM_SEND_DATA_REQ",
	[1318] = "SYSCODE_TRANS_COM_SEND_DATA_RSP",
	[1319] = "SYSCODE_TRANS_COM_RECV_DATA_REQ",
	[1320] = "SYSCODE_TRANS_COM_RECV_DATA_RSP",
	[1321] = "SYSCODE_TRANS_COM_SET_UP_CFG_REQ",
	[1322] = "SYSCODE_TRANS_COM_SET_UP_CFG_RSP",
	[1323] = "SYSCODE_TRANS_COM_GET_UP_CFG_REQ",
	[1324] = "SYSCODE_TRANS_COM_GET_UP_CFG_RSP",
	[1340] = "SYSCODE_GET_ELECTRIC_POWER_ALARM_CFG",
	[1342] = "SYSCODE_SET_ELECTRIC_POWER_ALARM_CFG",
	[1344] = "SYSCODE_GET_ELECTRIC_POWER_BATTERY_BASE_INFO",
	[1346] = "SYSCODE_SET_ELECTRIC_POWER_BATTERY_BASE_INFO",
	[1348] = "SYSCODE_GET_ELECTRIC_POWER_BATTERY_DEFAULT_CFG",
	[1350] = "SYSCODE_SET_ELECTRIC_POWER_BATTERY_DEFAULT_CFG",
	[1352] = "SYSCODE_GET_ELECTRIC_POWER_BATTERY_CFG",
	[1354] = "SYSCODE_SET_ELECTRIC_POWER_BATTERY_CFG",
	[1402] = "SYSCODE_3DPTZ_CAMERALINKAGE_REQ",
	[1404] = "SYSCODE_GET_CAMERALINKAGE_CFG_REQ",
	[1406] = "SYSCODE_SET_CAMERALINKAGE_CFG_REQ",
	----nvr----
	[3001] = "SYSCODE_GET_DEVICE_INFO",
	[3003] = "SYSCODE_SET_DEVICE_INFO",
	[3005] = "SYSCODE_GET_IP_CHAN_GROUP_INFO",
	[3007] = "SYSCODE_SET_IP_CHAN_INFO",
	[3009] = "SYSCODE_GET_IP_CHAN_GROUP_STATUS",
	[3013] = "SYSCODE_GET_NET_ADAPTER",
	[3015] = "SYSCODE_SET_NET_ADAPTER",
	[3017] = "SYSCODE_GET_SYNC_TIME",
	[3019] = "SYSCODE_SET_SYNC_TIME",
	[3021] = "SYSCODE_GET_RECORD_SCHEDULE",
	[3023] = "SYSCODE_SET_RECORD_SCHEDULE",
	[3026] = "SYSCODE_GET_ALARM_V40",
	----nvr end----
	----custom project----
	[3029] = "SYSCODE_GET_VEHICLE_DETECT_REQ",
	[3031] = "SYSCODE_SET_VEHICLE_DETECT_REQ",
	[3033] = "SYSCODE_GET_FLOAT_DETECT_REQ",
	[3035] = "SYSCODE_SET_FLOAT_DETECT_REQ",
	[3037] = "SYSCODE_GET_VEHICLE_SERVER_REQ",
	[3039] = "SYSCODE_SET_VEHICLE_SERVER_REQ",
	[3040] = "SYSCODE_GET_LIFTARM",
	[3041] = "SYSCODE_SET_LIFTARM",
	----custom project end----
	----alarm type expand----
	[0] = "SYSCODE_ALARM_TYPE_EXPAND_START",
	[1] = "SYSCODE_ELECTRICAL_LINE",
	[3028] = "SYSCODE_UPLOAD_PLATE",
	[65535] = "SYSCODE_ELECTRICAL_EXPAND_END",
	----alarm type expand----
	----NVD----
	[3101] = "SYSCODE_MATRIX_GET_CURRENT_MONITOR_LIST",
	[3103] = "SYSCODE_MATRIX_GET_CURRENT_LAYOUT",
	[3105] = "SYSCODE_MATRIX_GET_CURRENT_LAYOUT_INFO",
	[3107] = "SYSCODE_MATRIX_GET_CURRENT_PLAY_MODE",
	[3109] = "SYSCODE_MATRIX_START_LIVE",
	[3111] = "SYSCODE_MATRIX_START_LIVE_EX",
	[3113] = "SYSCODE_MATRIX_STOP_LIVE",
	[3115] = "SYSCODE_MATRIX_TOGGLE_FULL_SCREEN",
	[3117] = "SYSCODE_MATRIX_SWITCH_LAYOUT",
	[3119] = "SYSCODE_MATRIX_START_SWITCH_GROUP",
	[3121] = "SYSCODE_MATRIX_PAUSE_SWITCH_GROUP",
	[3123] = "SYSCODE_MATRIX_RESUME_SWITCH_GROUP",
	[3125] = "SYSCODE_MATRIX_PLAY_NEXT_GROUP",
	[3127] = "SYSCODE_MATRIX_PLAY_PRE_GROUP",
	[3129] = "SYSCODE_MATRIX_RESET_SWITCH_GROUP",
	[3131] = "SYSCODE_MATRIX_STOP_SWITCH_GROUP",
	[3133] = "SYSCODE_MATRIX_START_SUB_GROUP",
	----NVD end----
	---- add by dbw, for new interface ----
	[5001] = "SYSCODE_GET_SD_CARD_REQ",
	[5002] = "SYSCODE_GET_SD_CARD_RSP",
	[5003] = "SYSCODE_GET_DISK_FILES_REQ",
	[5004] = "SYSCODE_GET_DISK_FILES_RSP",
	---- add by dbw, for new interface ----

}

-- syscp
local syscp_tag = ProtoField.string("syscp.tag", "Tag", base.ASCII)
local syscp_version = ProtoField.uint8("syscp.version", "Version", base.DEC_HEX)
local syscp_hdr_len = ProtoField.uint8("syscp.hdr_len", "Header Length", base.DEC)
local syscp_type = ProtoField.uint16("syscp.type", "Type", base.UNIT_STRING, arr_syscp_type)
local syscp_attr_num = ProtoField.uint16("syscp.attr_num", "Attribution Numbers", base.DEC)
local syscp_seq = ProtoField.uint16("syscp.seq", "Sequence Number", base.DEC)
local syscp_session_id = ProtoField.uint16("syscp.session_id", "Session ID", base.DEC)
local syscp_total_len = ProtoField.uint16("syscp.total_len", "Total Length", base.DEC)

-- for test parameters
local syscp_test = ProtoField.uint32("syscp.test", "Test", base.HEX)

-- 将字段添加都协议中
syscp_proto.fields = {
	syscp_tag,
	syscp_version,
	syscp_hdr_len,
	syscp_type,
	syscp_attr_num,
	syscp_seq,
	syscp_session_id,
	syscp_total_len,
}

local data_dis = Dissector.get("data")

function syscp_module.parse(tvb, pinfo, treeitem)
	local offset = 0
	
	local syscp_tree = treeitem:add(syscp_proto, tvb:range(offset, 16))
	syscp_tree:add(syscp_tag, tvb:range(offset, 4))
	offset = offset + 4
	syscp_tree:add(syscp_version, tvb:range(offset, 1))
	offset = offset + 1
	syscp_tree:add(syscp_hdr_len, tvb:range(offset, 1))
	offset = offset + 1
	local _type = tvb:range(offset, 2):uint();
	syscp_tree:add(syscp_type, tvb:range(offset, 2))
	offset = offset + 2
	syscp_tree:add(syscp_attr_num, tvb:range(offset, 2))
	offset = offset + 2
	syscp_tree:add(syscp_seq, tvb:range(offset, 2))
	offset = offset + 2
	syscp_tree:add(syscp_session_id, tvb:range(offset, 2))
	offset = offset + 2
	local total_syscp_len = tvb:range(offset, 2):uint()
	syscp_tree:add(syscp_total_len, tvb:range(offset, 2))
	offset = offset + 2
	
	pinfo.cols.info:set("<GSSP> <SYSCP> <" .. arr_syscp_type[_type] .. ">")
	
	if (total_syscp_len ~= offset) then
		attr_module.parse(tvb:range(offset, total_syscp_len-offset):tvb(), pinfo, treeitem)
		offset = total_syscp_len
	end
--	data_dis:call(tvb:range(offset, total_syscp_len-offset):tvb(), pinfo, treeitem)

	return offset
end
