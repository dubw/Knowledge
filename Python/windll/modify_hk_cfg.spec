# -*- mode: python -*-

block_cipher = None


a = Analysis(['D:/python_tool/工具源码/modify_hk_h26x_32bit/modify_hk_cfg.py'],
             pathex=['D:\\python_tool\\工具源码\\modify_hk_h26x_32bit'],
             binaries=None,
             datas=None,
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='modify_hk_cfg',
          debug=False,
          strip=False,
          upx=True,
          console=False )
