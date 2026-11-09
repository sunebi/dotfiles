pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

import qs

Singleton {
  id: root

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property PwNode source: Pipewire.defaultAudioSource
  readonly property bool ready: sink?.ready ?? false
  readonly property real volume: sink?.audio?.volume ?? 0

  // Typed as list<var>: list<PwNode> breaks ScriptModel
  readonly property list<var> outputAppNodes: appNodes(true)
  readonly property list<var> inputAppNodes: appNodes(false)
  readonly property list<var> outputDevices: devices(true)
  readonly property list<var> inputDevices: devices(false)

  function deviceDisplayName(node) {
    return node.nickname || node.description || "Unknown";
  }

  function appNodeDisplayName(node) {
    return node.properties["application.name"] || node.description || node.name;
  }

  function isAudioNode(node, isSink) {
    return node.isSink === isSink && node.audio;
  }

  function appNodes(isSink) {
    return Pipewire.nodes.values.filter(node => isAudioNode(node, isSink) && node.isStream);
  }

  function devices(isSink) {
    return Pipewire.nodes.values.filter(node => isAudioNode(node, isSink) && !node.isStream);
  }

  function toggleMute() {
    if (sink?.audio)
      sink.audio.muted = !sink.audio.muted;
  }

  function toggleMicMute() {
    if (source?.audio)
      source.audio.muted = !source.audio.muted;
  }

  function incrementVolume() {
    setVolume(volume + currentVolumeStep());
  }

  function decrementVolume() {
    setVolume(volume - currentVolumeStep());
  }

  function setVolume(value) {
    if (sink?.audio)
      sink.audio.volume = Math.max(0, Math.min(Config.volumeMax, value));
  }

  function currentVolumeStep() {
    return volume < Config.fineVolumeThreshold ? Config.fineVolumeStep : Config.volumeStep;
  }

  function setDefaultSink(node) {
    Pipewire.preferredDefaultAudioSink = node;
  }

  function setDefaultSource(node) {
    Pipewire.preferredDefaultAudioSource = node;
  }

  PwObjectTracker {
    objects: [root.sink, root.source]
  }
}
