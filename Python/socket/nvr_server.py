import sys
import socket
import time
import server_class as s
import struct

while True:
    host = input("Input Server IP: ")
    port = input("Input Server Port: ")
#host = '10.0.0.226'
#port = 8081
    try:
        serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        serversocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        serversocket.bind((host, int(port)))

        serversocket.listen(1)
        break
    except Exception as e:
        print(e)
        continue
    #print("host:%s, port:%d" % (host, port))

hdr = s.MSG_HEADER()


while True:
    print("Begin to accept !")
    client, caddr = serversocket.accept()

    print ("client ip: " + str(caddr))

    req_hdr = s.MSG_HEADER()
    data_tmp = client.recv(24)
    print("Header Len: ", len(data_tmp))
    req_hdr.byMagic[0],req_hdr.byMagic[1],req_hdr.byMagic[2],req_hdr.byMagic[3], req_hdr.uVersion, req_hdr.usType, req_hdr.usAttrCount, req_hdr.uTotalLen, req_hdr.uSeqNum, req_hdr.uCheckSum = struct.unpack("<4BIHHIII", data_tmp)
    print(req_hdr.byMagic[0],req_hdr.byMagic[1],req_hdr.byMagic[2],req_hdr.byMagic[3], req_hdr.uVersion, req_hdr.usType, req_hdr.usAttrCount, req_hdr.uTotalLen, req_hdr.uSeqNum, req_hdr.uCheckSum)
    if (req_hdr.byMagic[0] != ord('A') or req_hdr.byMagic[1] != ord('L') or req_hdr.byMagic[2] != ord('R') or req_hdr.byMagic[3] != ord('M')):
        print("magic fail")
        #print(ord('A'), ord('L'), ord('R'), ord('M'))
    if (req_hdr.uVersion != 1 or req_hdr.usType != 0x100 or req_hdr.usAttrCount != 1 or req_hdr.uTotalLen <= 72 or req_hdr.uSeqNum != 0 or req_hdr.uCheckSum != 0):
        print("other failed")

    req_attr = s.ALARM_INFO()
    data_tmp = client.recv(48)
    print("Attr Len: ", len(data_tmp))
    print(data_tmp)
    req_attr.uAlarmType, description, req_attr.strTime, req_attr.uSnapshotDataLen, req_attr.byHistory, req_attr.byReverved = struct.unpack("<I16s20sIs3s", data_tmp)
    print(req_attr.uAlarmType, description, req_attr.strTime, req_attr.uSnapshotDataLen, req_attr.byHistory, req_attr.byReverved)

    left_len = req_hdr.uTotalLen - 72
    total_len = left_len
    read_len = 0
    data = bytes()
    while left_len > 0:
        rcvdata = client.recv(left_len)
        data += rcvdata
        left_len -= len(rcvdata)
        read_len += len(rcvdata)
        #print("read len:%d" % len(rcvdata))
    print("Picture Len: %d" % read_len)

    with open("received.jpg", "wb") as f:
        f.write(data)

    reply = s.MSG_HEADER()
    reply.byMagic[0] = ord('A')
    reply.byMagic[1] = ord('L')
    reply.byMagic[2] = ord('R')
    reply.byMagic[3] = ord('M')
    reply.uVersion = 1
    reply.usType = 0x100
    reply.usAttrCount = 1
    reply.uTotalLen = 24 + 8
    reply.uSeqNum =  0
    reply.uCheckSum = 0

    reply2 = s.MESSAGECODE()
    reply2.iMessageCode = 0
    reply2.iMessageLen = 0

    pack_hdr = struct.pack("<4BI2H3I",
                       reply.byMagic[0], reply.byMagic[1], reply.byMagic[2], reply.byMagic[3],
                       reply.uVersion, reply.usType, reply.usAttrCount, reply.uTotalLen,
                       reply.uSeqNum, reply.uCheckSum)
    pack_body = struct.pack("<2I", reply2.iMessageCode, reply2.iMessageLen)
    pack = pack_hdr + pack_body
    #print(len(pack))

    client.send(pack)
    time.sleep(1)
    client.close()
