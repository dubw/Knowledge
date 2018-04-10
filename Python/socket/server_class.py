import ctypes


class MSG_HEADER(ctypes.Structure):
    _fields_ = [('byMagic', ctypes.c_ubyte * 4),
                ('uVersion', ctypes.c_uint),
                ('usType', ctypes.c_ushort),
                ('usAttrCount', ctypes.c_ushort),
                ('uTotalLen', ctypes.c_uint),
                ('uSeqNum', ctypes.c_uint),
                ('uCheckSum', ctypes.c_uint)]
    #def __str__(self):
        #return (str(self.byMagic) + str(bin(self.uVersion)))

'''
/*消息头定义*/
typedef struct tagMsgHeader
{
    unsigned char   byMagic[4];     /*固定为’A’,’L’,’R’,’M’,用于消息同步*/
    unsigned int    uVersion;      /*当前消息版本号,保留固定为1*/
    unsigned short  usType;         /*消息类型,固定为MSG_TYPE_ALARM(0x100)*/
    unsigned short  usAttrCount;   /*消息体个数,固定为1包括报警信息和抓拍图片或者平台回应*/ 
    unsigned int    uTotalLen;    /*消息总长度,消息头长度+消息体长度+抓拍图片长度*/
    unsigned int    uSeqNum;       /*消息序号,保留字段,固定为0*/
    unsigned int    uCheckSum;     /*消息校验和,保留字段,固定为0*/
}MSG_HEADER;
'''

class MESSAGECODE(ctypes.Structure):
    _fields_ = [('iMessageCode', ctypes.c_int),
                ('iMessageLen', ctypes.c_int)]
    def __str__(self):
        return (str(bin(self.iMessageCode)) + str(bin(self.iMessageLen)))

'''
/*第三方报警平台回应*/
typedef struct tagMessageCode
{
    int iMessageCode;       /* 执行结果，0表示成功，其他表示失败,见附录*/
    int iMessageLen;        /* 反馈信息长度,固定为0*/
} MESSAGECODE;
'''

class ALARM_INFO(ctypes.Structure):
    _fields_ = [('uAlarmType', ctypes.c_uint),
                ('strDescription', ctypes.c_byte * 16),
                ('strTime', ctypes.c_char * 20),
                ('uSnapshotDataLen', ctypes.c_uint),
                ('byHistory', ctypes.c_char),
                ('byReverved', ctypes.c_char * 3)]
'''
#define  ALARM_TYPE_EVENT_SNAPSHOT  (1) 
/*IPC上报报警信息定义*/
typedef struct tagAlarmInfo
{
  unsigned int uAlarmType;              /*固定为ALARM_TYPE_EVENT_SNAPSHOT(1)*/
  char         strDescription[16];     /*消息描述,由GMI定义,第三方平台需转发或者显示该消息描述*/
  char         strTime[20];            /*报警时间yyyymmddHHMMSSxxx,年月日时分秒毫秒信息*/
  unsigned int uSnapshotDataLen;       /*抓拍图片数据长度*/
  char         byHistory;              /*1:历史抓拍图片 0:实时抓拍图片*/
  char         byReverved[3];         /*保留字段,固定为0*/
}ALARM_INFO;
'''