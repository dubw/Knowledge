import socket
import server_class as s
import struct
import sys,os
import time
import ctypes

'''
if len(sys.argv) != 3:
    print("nvr_client.exe: Invalid option")
    print("Usage: nvr_client.exe ip port")
    exit(-1)
'''
#host='10.0.0.226'
#port=8081
#host = sys.argv[1]
#host = sys.argv[2]


req_hdr = s.MSG_HEADER()
req_attr = s.ALARM_INFO()

while True:
    piclen = 0
    fdata = b""
    picname = ""
    description = b""
    description_c16 = (ctypes.c_byte * 16)()
    picindex = input("Input Alarm Type: (1-substitution, 2-yawn, 3-offpost)")
    if picindex != "1" and picindex != "2" and picindex != "3":
        print("Invalid Alarm Type.")
        continue
    try:
        if picindex == "1":
            picname = "substitution.jpg"
            description = b'\x09\x00'
            description_c16[0] = int('9', 16)
            description_c16[1] = int('0', 16)
        elif picindex == "2":
            picname = "yawn.jpg"
            description = b'\x06\x00'
            description_c16[0] = int('6', 16)
            description_c16[1] = int('0', 16)
        elif picindex == "3":
            picname = "offpost.jpg"
            description = b'\x00\x02'
            description_c16[0] = int('0', 16)
            description_c16[1] = int('2', 16)
        else:
            picname = ""
            description = b""
            continue
        with open(picname, "rb") as f:
            fdata = f.read()
            piclen = len(fdata)
    except Exception as e:
        print("failed to open ", picname)
        os.system("pause")
        exit(-1)

    req_hdr.byMagic[0] = ord('A')
    req_hdr.byMagic[1] = ord('L')
    req_hdr.byMagic[2] = ord('R')
    req_hdr.byMagic[3] = ord('M')
    req_hdr.uVersion = 1
    req_hdr.usType = 0x100
    req_hdr.usAttrCount = 1
    req_hdr.uTotalLen = 24 + 48 + piclen
    req_hdr.uSeqNum = 0
    req_hdr.uCheckSum = 0
    pack_hdr = struct.pack("<4BI2H3I",
                           req_hdr.byMagic[0], req_hdr.byMagic[1], req_hdr.byMagic[2], req_hdr.byMagic[3],
                           req_hdr.uVersion, req_hdr.usType, req_hdr.usAttrCount, req_hdr.uTotalLen,
                           req_hdr.uSeqNum, req_hdr.uCheckSum)

    req_attr.uAlarmType = 1
    req_attr.strDescription = description_c16
    print("desc:%s, d:%s" % (req_attr.strDescription, description_c16))
    #req_attr.strTime = b"10086"
    t = time.strftime("%Y%m%d%H%M%S", time.localtime())
    t += "%03d" % (int(time.time()*1000)%1000)
    req_attr.strTime = t.encode()
    req_attr.uSnapshotDataLen = piclen
    req_attr.byHistory = b'\x00'
    req_attr.byReverved = b""
    pack_attr = struct.pack("<I16s20sIc3s", req_attr.uAlarmType, description, req_attr.strTime,
                            req_attr.uSnapshotDataLen, req_attr.byHistory, req_attr.byReverved)
    print(pack_attr)

    pack = pack_hdr + pack_attr + fdata

    host = input("Input Server IP: ")
    port = input("Input Server Port:")

    try:
        client=socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client.connect((host, int(port)))
        client.sendall(pack)
    except socket.error as se:
        print(se)
        continue

#rdata = client.recv(32)
#print(rdata)

    reply_hdr = s.MSG_HEADER()
    data_tmp = client.recv(24)
    print("Rcv Header Len: ", len(data_tmp))
    if len(data_tmp) != 24:
        print("Rcv Header Len Err")
        client.close()
        continue

    reply_hdr.byMagic[0], reply_hdr.byMagic[1], reply_hdr.byMagic[2], reply_hdr.byMagic[
        3], reply_hdr.uVersion, reply_hdr.usType, reply_hdr.usAttrCount, reply_hdr.uTotalLen, reply_hdr.uSeqNum, reply_hdr.uCheckSum = struct.unpack(
        "<4BIHHIII", data_tmp)
    print(reply_hdr.byMagic[0], reply_hdr.byMagic[1], reply_hdr.byMagic[2], reply_hdr.byMagic[3], reply_hdr.uVersion, reply_hdr.usType,
          reply_hdr.usAttrCount, reply_hdr.uTotalLen, reply_hdr.uSeqNum, reply_hdr.uCheckSum)
    if (reply_hdr.byMagic[0] != ord('A') or reply_hdr.byMagic[1] != ord('L') or reply_hdr.byMagic[2] != ord('R') or
            reply_hdr.byMagic[3] != ord('M')):
        print("magic fail")
    if (reply_hdr.uVersion != 1 or reply_hdr.usType != 0x100 or reply_hdr.usAttrCount != 1 or reply_hdr.uTotalLen != 32 or reply_hdr.uSeqNum != 0 or reply_hdr.uCheckSum != 0):
        print("other failed")

    reply_body = s.MESSAGECODE()
    data_tmp = client.recv(8)
    print("Rcv Message Code Len:", len(data_tmp))
    reply_body.iMessageCode, reply_body.iMessageLen = struct.unpack("<2i", data_tmp)
    print("code: %d, Len: %d" % (reply_body.iMessageCode, reply_body.iMessageLen))
    if (reply_body.iMessageCode == 0):
        print("Rcv ok")
    else:
        print("Rcv fail")
    client.close()
