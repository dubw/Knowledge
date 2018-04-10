import ctypes
import os
import logging

path1 = os.path.join(os.getcwd(), "hklib_32")
path2 = os.path.join(os.getcwd(), "hklib_32\HCNetSDKCom")
os.environ['path'] += ';' + path1
os.environ['path'] += ';' + path2

dll = ctypes.WinDLL("HCNetSDK.dll")

def connect(ip, port, name, passwd):
    struLoginInfo = NET_DVR_USER_LOGIN_INFO()
    struLoginInfo.sDeviceAddress = ip.encode('utf-8')
    struLoginInfo.wPort = int(port)
    struLoginInfo.sUserName = name.encode('utf-8')
    struLoginInfo.sPassword = passwd.encode('utf-8')

    devinfo_v40 = NET_DVR_DEVICEINFO_V40()

    userid = dll.NET_DVR_Login_V40(ctypes.byref(struLoginInfo),
                                   ctypes.byref(devinfo_v40))
    return userid, devinfo_v40


def handle(ip, port, name, passwd):
    logging.info("ip:%s, port:%s, name:%s, passwd:%s" % (ip, port, name, passwd))

    dll.NET_DVR_Init()

    userid, devinfo = connect(ip, port, name, passwd)
    if userid < 0:
        logging.error("Connect err, errno:%d" % dll.NET_DVR_GetLastError())
        dll.NET_DVR_Cleanup()
        return False

    ret = get_h26x_info(userid, devinfo.struDeviceV30.byStartChan)

    dll.NET_DVR_Logout(userid)
    dll.NET_DVR_Cleanup()
    return ret

NET_DVR_DEV_ADDRESS_MAX_LEN = 129
NET_DVR_LOGIN_USERNAME_MAX_LEN = 64
NET_DVR_LOGIN_PASSWD_MAX_LEN = 64


class NET_DVR_USER_LOGIN_INFO(ctypes.Structure):
    _fields_ = [('sDeviceAddress', ctypes.c_char * NET_DVR_DEV_ADDRESS_MAX_LEN),
                ('byRes1', ctypes.c_uint8),
                ('wPort', ctypes.c_uint16),
                ('sUserName', ctypes.c_char * NET_DVR_LOGIN_USERNAME_MAX_LEN),
                ('sPassword', ctypes.c_char * NET_DVR_LOGIN_PASSWD_MAX_LEN),
                ('cbLoginResult', ctypes.c_void_p),
                ('pUser', ctypes.c_void_p),
                ('bUseAsynLogin', ctypes.c_int),
                ('byRes2', ctypes.c_ubyte * 128)]

'''
struct{
  char                    sDeviceAddress[NET_DVR_DEV_ADDRESS_MAX_LEN];
  BYTE                    byRes1;
  WORD                    wPort;
  char                    sUserName[NET_DVR_LOGIN_USERNAME_MAX_LEN];
  char                    sPassword[NET_DVR_LOGIN_PASSWD_MAX_LEN];
  fLoginResultCallBack    cbLoginResult;
  void                    *pUser;
  BOOL                    bUseAsynLogin;
  BYTE                    byRes2[128];
}NET_DVR_USER_LOGIN_INFO,*LPNET_DVR_USER_LOGIN_INFO;
'''

SERIALNO_LEN = 48

class NET_DVR_DEVICEINFO_V30(ctypes.Structure):
    _fields_ = [('sSerialNumber', ctypes.c_uint8 * SERIALNO_LEN),
                ('byAlarmInPortNum', ctypes.c_uint8),
                ('byAlarmOutPortNum', ctypes.c_uint8),
                ('byDiskNum', ctypes.c_uint8),
                ('byDVRType', ctypes.c_uint8),
                ('byChanNum', ctypes.c_uint8),
                ('byStartChan', ctypes.c_uint8),
                ('byAudioChanNum', ctypes.c_uint8),
                ('byIPChanNum', ctypes.c_uint8),
                ('byZeroChanNum', ctypes.c_uint8),
                ('byMainProto', ctypes.c_uint8),
                ('bySubProto', ctypes.c_uint8),
                ('bySupport', ctypes.c_uint8),
                ('bySupport1', ctypes.c_uint8),
                ('bySupport2', ctypes.c_uint8),
                ('wDevType', ctypes.c_uint16),
                ('bySupport3', ctypes.c_uint8),
                ('byMultiStreamProto', ctypes.c_uint8),
                ('byStartDChan', ctypes.c_uint8),
                ('byStartDTalkChan', ctypes.c_uint8),
                ('byHighDChanNum', ctypes.c_uint8),
                ('bySupport4', ctypes.c_uint8),
                ('byLanguageType', ctypes.c_uint8),
                ('byVoiceInChanNum', ctypes.c_uint8),
                ('byStartVoiceInChanNo', ctypes.c_uint8),
                ('byRes3', ctypes.c_uint8 * 2),
                ('byMirrorChanNum', ctypes.c_uint8),
                ('wStartMirrorChanNo', ctypes.c_uint16),
                ('byRes2', ctypes.c_uint8 * 2)]


'''
struct{
  BYTE     sSerialNumber[SERIALNO_LEN];
  BYTE     byAlarmInPortNum;
  BYTE     byAlarmOutPortNum;
  BYTE     byDiskNum;
  BYTE     byDVRType;
  BYTE     byChanNum;
  BYTE     byStartChan;
  BYTE     byAudioChanNum;
  BYTE     byIPChanNum;
  BYTE     byZeroChanNum;
  BYTE     byMainProto;
  BYTE     bySubProto;
  BYTE     bySupport;
  BYTE     bySupport1;
  BYTE     bySupport2;
  WORD     wDevType;
  BYTE     bySupport3;
  BYTE     byMultiStreamProto;
  BYTE     byStartDChan;
  BYTE     byStartDTalkChan;
  BYTE     byHighDChanNum;
  BYTE     bySupport4;
  BYTE     byLanguageType;
  BYTE     byVoiceInChanNum;
  BYTE     byStartVoiceInChanNo;
  BYTE     byRes3[2];
  BYTE     byMirrorChanNum;
  WORD     wStartMirrorChanNo;
  BYTE     byRes2[2];
}NET_DVR_DEVICEINFO_V30,*LPNET_DVR_DEVICEINFO_V30;
'''


class NET_DVR_DEVICEINFO_V40(ctypes.Structure):
    _fields_ = [('struDeviceV30', NET_DVR_DEVICEINFO_V30),
                ('bySupportLock', ctypes.c_uint8),
                ('byRetryLoginTime', ctypes.c_uint8),
                ('byPasswordLevel', ctypes.c_uint8),
                ('byRes1', ctypes.c_uint8),
                ('dwSurplusLockTime', ctypes.c_ulong),
                ('byCharEncodeType', ctypes.c_uint8),
                ('byRes2', ctypes.c_uint8 * 255)]


'''
struct{  
  NET_DVR_DEVICEINFO_V30    struDeviceV30;
  BYTE                      bySupportLock;
  BYTE                      byRetryLoginTime;
  BYTE                      byPasswordLevel;  
  BYTE                      byRes1;
  DWORD                     dwSurplusLockTime;
  BYTE                      byCharEncodeType;
  BYTE                      byRes2[255];
}NET_DVR_DEVICEINFO_V40,*LPNET_DVR_DEVICEINFO_V40;
'''


def get_h26x_info(userid, channel):
    logging.info("userid: %d, channel: %d" % (userid, channel))

    main = NET_DVR_COMPRESSION_INFO_V30()
    reserve = NET_DVR_COMPRESSION_INFO_V30()
    event = NET_DVR_COMPRESSION_INFO_V30()
    sub = NET_DVR_COMPRESSION_INFO_V30()

    info = NET_DVR_COMPRESSIONCFG_V30()
    info.struNormHighRecordPara = main
    info.struRes = reserve
    info.struEventRecordPara = event
    info.struNetPara = sub

    len = ctypes.c_ulong()
    ret = dll.NET_DVR_GetDVRConfig(userid, NET_DVR_GET_COMPRESSCFG_V30, channel, ctypes.byref(info),
                                   ctypes.sizeof(NET_DVR_COMPRESSIONCFG_V30), ctypes.byref(len))
    if ret:
        logging.info("encode type[h264(0,1) or h265(10)]: %d" % info.struNormHighRecordPara.byVideoEncType)
        if info.struNormHighRecordPara.byVideoEncType == 10:
            logging.info("This Main Stream is H265 encode, need to be changed")
            info.struNormHighRecordPara.byVideoEncType = 1
            ret = dll.NET_DVR_SetDVRConfig(userid, NET_DVR_SET_COMPRESSCFG_V30, channel, ctypes.byref(info),
                                           ctypes.sizeof(NET_DVR_COMPRESSIONCFG_V30))
            if ret:
                logging.info("Change OK")
            else:
                logging.error("Change Failed. NET_DVR_SetDVRConfig Failed, errno:%d" % dll.NET_DVR_GetLastError())
        else:
            logging.info("No need to change encode.")
            ret = False
    else:
        logging.error("NET_DVR_GetDVRConfig Failed, errno:%d" % dll.NET_DVR_GetLastError())

    return ret


NET_DVR_GET_COMPRESSCFG_V30 = 1040
NET_DVR_SET_COMPRESSCFG_V30 = 1041


class NET_DVR_COMPRESSION_INFO_V30(ctypes.Structure):
    _fields_ = [('byStreamType', ctypes.c_uint8),
                ('byResolution', ctypes.c_uint8),
                ('byBitrateType', ctypes.c_uint8),
                ('byPicQuality', ctypes.c_uint8),
                ('dwVideoBitrate', ctypes.c_ulong),
                ('dwVideoFrameRate', ctypes.c_ulong),
                ('wIntervalFrameI', ctypes.c_uint16),
                ('byIntervalBPFrame', ctypes.c_uint8),
                ('byres1', ctypes.c_uint8),
                ('byVideoEncType', ctypes.c_uint8),
                ('byAudioEncType', ctypes.c_uint8),
                ('byVideoEncComplexity', ctypes.c_uint8),
                ('byEnableSvc', ctypes.c_uint8),
                ('byFormatType', ctypes.c_uint8),
                ('byAudioBitRate', ctypes.c_uint8),
                ('bySteamSmooth', ctypes.c_uint8),
                ('byAudioSamplingRate', ctypes.c_uint8),
                ('bySmartCodec', ctypes.c_uint8),
                ('byres', ctypes.c_uint8),
                ('wAverageVideoBitrate', ctypes.c_uint16)]


"""
struct{  
  BYTE     byStreamType;
  BYTE     byResolution;  
  BYTE     byBitrateType;
  BYTE     byPicQuality;  
  DWORD    dwVideoBitrate;  
  DWORD    dwVideoFrameRate;
  WORD     wIntervalFrameI;  
  BYTE     byIntervalBPFrame;  
  BYTE     byres1;
  BYTE     byVideoEncType;  
  BYTE     byAudioEncType;
  BYTE     byVideoEncComplexity;  
  BYTE     byEnableSvc;  
  BYTE     byFormatType;
  BYTE     byAudioBitRate;  
  BYTE     bySteamSmooth;
  BYTE     byAudioSamplingRate;  
  BYTE     bySmartCodec;  
  BYTE     byres;
  WORD     wAverageVideoBitrate;
}NET_DVR_COMPRESSION_INFO_V30, *LPNET_DVR_COMPRESSION_INFO_V30;
"""


class NET_DVR_COMPRESSIONCFG_V30(ctypes.Structure):
    _fields_ = [('dwSize', ctypes.c_ulong),
                ('struNormHighRecordPara', NET_DVR_COMPRESSION_INFO_V30),
                ('struRes', NET_DVR_COMPRESSION_INFO_V30),
                ('struEventRecordPara', NET_DVR_COMPRESSION_INFO_V30),
                ('struNetPara', NET_DVR_COMPRESSION_INFO_V30)]


"""
struct{  
  DWORD                           dwSize;
  NET_DVR_COMPRESSION_INFO_V30    struNormHighRecordPara;
  NET_DVR_COMPRESSION_INFO_V30    struRes;
  NET_DVR_COMPRESSION_INFO_V30    struEventRecordPara;
  NET_DVR_COMPRESSION_INFO_V30    struNetPara;
}NET_DVR_COMPRESSIONCFG_V30, *LPNET_DVR_COMPRESSIONCFG_V30;
"""
