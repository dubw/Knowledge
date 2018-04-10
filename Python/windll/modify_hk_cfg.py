import time
import os
import csv
import hk_sdk
import logging
import logging.handlers
import telnetlib


def get_ipc_list():
    items = []
    filename = "hk_ipc.csv"
    if os.path.exists(filename):
        with open(filename, "r") as csvfile:
            read = csv.reader(csvfile)
            for i in read:
                items.append(i)
    else:
        f = open(filename, 'w')
        f.close()
    return items


def telnet_cmd(tn, cmd, timeout=10):
    tn.write(cmd.encode('ascii') + b'\n')
    ret = tn.read_until(b'#', timeout)
    inx = ret.find(b"#")
    if inx == -1:
        logging.info("Run cmd:%s Failed", cmd)
        return False
    else:
        logging.info("Run cmd:%s OK", cmd)
        return True


def run_decode_sh(ip):
    logging.info("Begin to telnet Decoder, ip:%s" % ip)
    timeout = 10
    # 连接Telnet服务器
    tn = telnetlib.Telnet(ip, 23, timeout)
    tn.set_debuglevel(2)
    # 输入登录用户名
    tn.read_until(b"login: ")
    tn.write("root".encode('ascii') + b'\n')
    tn.read_until(b'Password: ', timeout)
    tn.write(b'\n')
    ret = tn.read_until(b"#", timeout)
    if ord('#') != ret[-1]:
        logging.error("Telnet Login Failed!")
        return
    else:
        logging.info("Telnet Login Success")

        cmd = "/opt/bin/modify_hk_cfg.sh"
        telnet_cmd(tn, cmd)

        tn.close()


def detect_and_change(cfg_items):
    for item in cfg_items:
        ret = hk_sdk.handle(item[0], item[1], item[2], item[3])
        if ret:
            # wait 1 sec to enable hk_sdk modification
            time.sleep(1)
            run_decode_sh(item[4])


def main():
    while 1:
        logging.info("=====================")
        logging.info("Start ...")
        ipclist = get_ipc_list()
        if len(ipclist) != 0:
            detect_and_change(ipclist)
        else:
            logging.info("No ipc list")
        logging.info("End ...")
        sleept = ipclist[-1][5]
        logging.info("=====================sleep:%d" % int(sleept))
        time.sleep(int(sleept))


LOG_FILE = "modify_hk_cfg.log"
if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
                        datefmt='%a, %d %b %Y %H:%M:%S',
                        filename=LOG_FILE,
                        filemode='w')

    #################################################################################################
    # 定义一个StreamHandler，将INFO级别或更高的日志信息打印到标准错误，并将其添加到当前的日志处理对象#
    console = logging.StreamHandler()
    console.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
    console.setFormatter(formatter)
    logging.getLogger('').addHandler(console)
    #################################################################################################
    #################################################################################################
    # 定义一个RotatingFileHandler，最多备份5个日志文件，每个日志文件最大10M
    Rthandler = logging.handlers.RotatingFileHandler(LOG_FILE, maxBytes=1024 * 1024, backupCount=2)
    Rthandler.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
    Rthandler.setFormatter(formatter)
    logging.getLogger('').addHandler(Rthandler)
    ################################################################################################
    main()

'''
    fmt = '%(asctime)s - %(filename)s:%(lineno)s - %(name)s - %(message)s'
    formatter = logging.Formatter(fmt)  # 实例化formatter
    handler.setFormatter(formatter)  # 为handler添加formatter
    logger = logging.getLogger('')  # 获取名为mylog的logger
    logger.addHandler(handler)  # 为logger添加handler
    logger.setLevel(logging.DEBUG)
'''
