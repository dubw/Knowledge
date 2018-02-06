#test under python3.5.4
import wx

class MyFrame(wx.Frame):
    def __init__(self, parent):
        self.frame_width = 1025.0
        self.frame_height = 760.0
        wx.Frame.__init__(self, parent, -1, u"火焰检测", size=(self.frame_width, self.frame_height))
        icon = wx.Icon("gmi_logo.png", wx.BITMAP_TYPE_PNG)
        self.SetIcon(icon)
        self.panel = wx.Panel(self, -1)
        self.SetBackgroundColour((49,60,66))

        vbox = wx.BoxSizer(wx.VERTICAL)
        hbox1 = wx.BoxSizer(wx.HORIZONTAL)
        url_text = wx.StaticText(self.panel, -1, "URL:")
        url_text.SetForegroundColour('white')
        self.url = wx.TextCtrl(self.panel, -1, "", style=wx.BORDER_NONE | wx.TE_NOHIDESEL)
        self.url.SetForegroundColour('white')
        self.url.SetBackgroundColour((79,84,90))#((135,141,150))
        self.url.SetValue("http://hls.open.ys7.com/openlive/ada7a4e2aa134dea8a546634bc33627d.hd.m3u8")
        self.conn_btn = wx.Button(self.panel, label=u"连接", style=wx.BORDER_NONE)
        self.conn_btn.SetBackgroundColour('black')
        self.conn_btn.SetForegroundColour('white')
        self.conn_btn.Bind(wx.EVT_BUTTON, self.OnConn)
        hbox1.Add(url_text, 0, wx.ALIGN_CENTRE_VERTICAL)
        hbox1.Add(self.url, 1,  wx.ALIGN_CENTRE_VERTICAL| wx.EXPAND|wx.LEFT, 10)
        hbox1.Add(self.conn_btn, 0,  wx.LEFT, 10)
        vbox.Add(hbox1, 0,  wx.LEFT | wx.RIGHT | wx.TOP | wx.EXPAND , 20)
        vbox.Add((-1, 10))

        self.bmp_width = 480
        self.bmp_height = 270
        self.bmp_ratio_x = self.frame_width / self.bmp_width
        self.bmp_ratio_y = self.frame_height / self.bmp_height

        hbox_media = wx.BoxSizer(wx.HORIZONTAL)
        vbox_media = wx.BoxSizer(wx.VERTICAL)
        vbox_bmp = wx.BoxSizer(wx.VERTICAL)

        xbmp = wx.Image('1.jpg', wx.BITMAP_TYPE_JPEG).Scale(self.bmp_width,self.bmp_height)
        temp = xbmp.ConvertToBitmap()
        self.xmedia = wx.StaticBitmap(self.panel,-1,temp)
        self.xmedia.Bind(wx.EVT_SIZE, self.OnSize)
        self.media_text = wx.StaticText(self.panel, -1, u"实时视频", )
        self.media_text.SetForegroundColour('white')

        ximage = wx.Image('2.jpg', wx.BITMAP_TYPE_JPEG).Scale(self.bmp_width,self.bmp_height)
        temp2 = ximage.ConvertToBitmap()
        self.bmp = wx.StaticBitmap(self.panel,-1,temp2)
        self.bmp.Bind(wx.EVT_SIZE, self.OnSize)
        self.bmp_text = wx.StaticText(self.panel, -1, u"告警图像")
        self.bmp_text.SetForegroundColour('white')

        vbox_media.Add(self.xmedia, 1)
        vbox_media.Add((-1,5))
        vbox_media.Add(self.media_text, 0, wx.ALIGN_CENTER_HORIZONTAL)
        vbox_bmp.Add(self.bmp, 1)
        vbox_bmp.Add((-1,5))
        vbox_bmp.Add(self.bmp_text, 0, wx.ALIGN_CENTER_HORIZONTAL)
        hbox_media.Add(vbox_media, 0, wx.EXPAND)
        hbox_media.Add(vbox_bmp, 0,  wx.EXPAND|wx.LEFT, 10)
        vbox.Add(hbox_media, 0,  wx.EXPAND  | wx.LEFT | wx.RIGHT, 20)
        vbox.Add((-1, 10))

        hbox3 = wx.BoxSizer(wx.HORIZONTAL)

        self.filelist = wx.ListCtrl(self.panel, -1, style=wx.LC_REPORT | wx.BORDER_NONE)
        self.filelist.InsertColumn(0, u"文件名", width=440)
        self.filelist.InsertColumn(1, u"报警时间", width=260)
        self.filelist.InsertColumn(2, u"报警类型", width=260)
        self.filelist.SetForegroundColour('white')
        self.filelist.SetBackgroundColour((79,84,90))
        hbox3.Add(self.filelist, 1, wx.EXPAND)
        vbox.Add(hbox3, 1, wx.LEFT | wx.RIGHT | wx.BOTTOM | wx.EXPAND, 20)

        self.panel.SetSizer(vbox)
        self.Centre()
        self.Bind(wx.EVT_MAXIMIZE, self.OnMaxi)
        self.Bind(wx.EVT_SIZE, self.OnSize)
        self.max_state = 0

    def OnSize(self, event):
        rect = self.GetRect()
        x = float(rect.width / self.bmp_ratio_x)
        y = float(rect.height / self.bmp_ratio_y)
        ratio = 16/9
        if x/y > ratio:
            y = x/ratio
        else:
            x = ratio * y
        if (self.IsMaximized()):
            self.max_state = 1
        elif self.xmedia.GetId() == event.GetId():
            print("in Onsize xmedia")
            media = wx.Image('1.jpg', wx.BITMAP_TYPE_JPEG)
            temp = media.Scale(x, y).ConvertToBitmap()
            self.xmedia.SetBitmap(temp)
            self.Refresh()
        elif self.bmp.GetId() == event.GetId():
            print("in Onsize bmp")
            self.ximage = wx.Image('2.jpg', wx.BITMAP_TYPE_JPEG)
            temp = self.ximage.Scale(x, y).ConvertToBitmap()
            self.bmp.SetBitmap(temp)
            self.Refresh()
        elif self.max_state == 1:
            print("in Onsize maxi")
            media = wx.Image('1.jpg', wx.BITMAP_TYPE_JPEG)
            temp = media.Scale(x, y).ConvertToBitmap()
            self.xmedia.SetBitmap(temp)
            self.ximage = wx.Image('2.jpg', wx.BITMAP_TYPE_JPEG)
            temp = self.ximage.Scale(x, y).ConvertToBitmap()
            self.bmp.SetBitmap(temp)
            self.Update()
        event.Skip()

    def OnMaxi(self, event):
        print("in OnMaxi")
        rect = self.GetRect()
        x = float(rect.width / self.bmp_ratio_x)
        y = float(rect.height / self.bmp_ratio_y)
        ratio = 16/9
        if x/y > ratio:
            y = x/ratio
        else:
            x = ratio * y

        media = wx.Image('1.jpg', wx.BITMAP_TYPE_JPEG)
        temp = media.Scale(x, y).ConvertToBitmap()
        self.xmedia.SetBitmap(temp)
        self.ximage = wx.Image('2.jpg', wx.BITMAP_TYPE_JPEG)
        temp = self.ximage.Scale(x, y).ConvertToBitmap()
        self.bmp.SetBitmap(temp)
        event.Skip()

    def OnConn(self, event):
        print("in OnConn")

class MyApp(wx.App):  
    def OnInit(self):  
        self.framework = MyFrame(None)  
        self.framework.Show(True)
        self.SetTopWindow(self.framework)
        return True


app = MyApp()
app.MainLoop()



