import { app, BrowserWindow, globalShortcut } from "electron";
import path from "path";

// eslint-disable-next-line no-undef
const IS_DEV = process.env.IS_IN_DEVELOPMENT || false;

function createWindow() {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      enableRemoteModule: true,
      devTools: IS_DEV || !app.isPackaged,
    },
  });

  win.setMenu(null);
  win.maximize();

  globalShortcut.register("f5", function () {
    win.reload();
  });
  globalShortcut.register("CommandOrControl+R", function () {
    win.reload();
  });

  if (IS_DEV) {
    win.loadURL("http://localhost:5173");
    win.webContents.openDevTools();
  } else {
    // eslint-disable-next-line no-undef
    win.loadURL(`file://${path.join(__dirname, "index.html")}`);
  }
}

app.whenReady().then(createWindow);

app.on("window-all-closed", () => {
  // eslint-disable-next-line no-undef
  if (process.platform !== "darwin") {
    app.quit();
  }
});

app.on("activate", () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
