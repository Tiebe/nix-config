#!/usr/bin/env python3

from signal import SIGINT, SIGTERM, signal
from subprocess import Popen, check_output

from hid import device
from hid import enumerate as hidenumerate

CMD_PACTL = "pactl"
CMD_PWLOOPBACK = "pw-loopback"


class ChatMix:
  def __init__(self, output_sink: str, main_sink: str, chat_sink: str):
    self.main_sink = main_sink
    self.chat_sink = chat_sink
    self.main_sink_process = self._create_virtual_sink(main_sink, output_sink)
    self.chat_sink_process = self._create_virtual_sink(chat_sink, output_sink)

  def set_main_volume(self, volume: int):
    self._set_volume(self.main_sink, volume)

  def set_chat_volume(self, volume: int):
    self._set_volume(self.chat_sink, volume)

  def set_volumes(self, main_volume: int, chat_volume: int):
    self.set_main_volume(main_volume)
    self.set_chat_volume(chat_volume)

  def close(self):
    self.main_sink_process.terminate()
    self.chat_sink_process.terminate()

  def _create_virtual_sink(self, name: str, output_sink: str) -> Popen:
    return Popen(
      [
        CMD_PWLOOPBACK,
        "-P",
        output_sink,
        "--capture-props=media.class=Audio/Sink",
        "-n",
        name,
      ]
    )

  def _set_volume(self, sink: str, volume: int):
    Popen([CMD_PACTL, "set-sink-volume", f"input.{sink}", f"{volume}%"])


class NovaProWireless:
  VID = 0x1038
  PID = 0x12E0
  INTERFACE = 0x4
  MSGLEN = 63
  READ_TIMEOUT = 1000
  TX = 0x6
  OPT_SONAR_ICON = 0x8D
  OPT_CHATMIX_ENABLE = 0x49
  OPT_CHATMIX = 0x45
  PW_OUTPUT_SINK_AUTODETECT = "SteelSeries_Arctis_Nova_Pro_Wireless"
  PW_GAME_SINK = "NovaGame"
  PW_CHAT_SINK = "NovaChat"
  CHATMIX_CONTROLS_ENABLED = False
  SONAR_ICON_ENABLED = False
  CLOSE = False
  ERR_NOTFOUND = "Device not found"

  def __init__(self, output_sink=None):
    devpath = None
    for hiddev in hidenumerate(self.VID, self.PID):
      if hiddev["interface_number"] == self.INTERFACE:
        devpath = hiddev["path"]
        break
    if not devpath:
      raise DeviceNotFoundException

    if not output_sink:
      sinks = check_output([CMD_PACTL, "list", "sinks", "short"]).decode().split("\n")
      for sink in sinks[:-1]:
        sink_name = sink.split("\t")[1]
        if self.PW_OUTPUT_SINK_AUTODETECT in sink_name:
          output_sink = sink_name

    self.dev = device()
    self.dev.open_path(devpath)
    self.dev.set_nonblocking(True)
    self.output_sink = output_sink

  def set_chatmix_controls(self, state: bool):
    assert self.dev, self.ERR_NOTFOUND
    self.dev.write(self._create_msgdata((self.TX, self.OPT_CHATMIX_ENABLE, int(state))))
    self.CHATMIX_CONTROLS_ENABLED = state

  def set_sonar_icon(self, state: bool):
    assert self.dev, self.ERR_NOTFOUND
    self.dev.write(self._create_msgdata((self.TX, self.OPT_SONAR_ICON, int(state))))
    self.SONAR_ICON_ENABLED = state

  def chatmix_volume_control(self, chatmix: ChatMix):
    assert self.dev, self.ERR_NOTFOUND
    while not self.CLOSE:
      try:
        msg = self.dev.read(self.MSGLEN, self.READ_TIMEOUT)
        if not msg or msg[1] != self.OPT_CHATMIX:
          continue
        gamevol = msg[2]
        chatvol = msg[3]
        chatmix.set_volumes(gamevol, chatvol)
      except OSError:
        self.CLOSE = True
    chatmix.close()

  def close(self, signum, frame):
    self.CLOSE = True
    if self.CHATMIX_CONTROLS_ENABLED:
      self.set_chatmix_controls(False)
    if self.SONAR_ICON_ENABLED:
      self.set_sonar_icon(False)

  def _create_msgdata(self, data: tuple[int, ...]) -> bytes:
    return bytes(data).ljust(self.MSGLEN, b"\0")


class DeviceNotFoundException(Exception):
  pass


if __name__ == "__main__":
  try:
    nova = NovaProWireless()
    nova.set_sonar_icon(state=True)
    nova.set_chatmix_controls(state=True)

    signal(SIGINT, nova.close)
    signal(SIGTERM, nova.close)

    assert nova.output_sink, "Output sink not set"
    chatmix = ChatMix(
      output_sink=nova.output_sink,
      main_sink=nova.PW_GAME_SINK,
      chat_sink=nova.PW_CHAT_SINK,
    )

    nova.chatmix_volume_control(chatmix=chatmix)
  except DeviceNotFoundException:
    raise SystemExit(0)
