# -*- coding: utf-8 -*-
# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: data.proto
# Protobuf Python Version: 4.25.1
"""Generated protocol buffer code."""
from google.protobuf import descriptor as _descriptor
from google.protobuf import descriptor_pool as _descriptor_pool
from google.protobuf import symbol_database as _symbol_database
from google.protobuf.internal import builder as _builder
# @@protoc_insertion_point(imports)

_sym_db = _symbol_database.Default()




DESCRIPTOR = _descriptor_pool.Default().AddSerializedFile(b'\n\ndata.proto\x12\rframetracking\"\xdb\x01\n\tMatrix4x4\x12\x0b\n\x03m00\x18\x01 \x01(\x02\x12\x0b\n\x03m01\x18\x02 \x01(\x02\x12\x0b\n\x03m02\x18\x03 \x01(\x02\x12\x0b\n\x03m03\x18\x04 \x01(\x02\x12\x0b\n\x03m10\x18\x05 \x01(\x02\x12\x0b\n\x03m11\x18\x06 \x01(\x02\x12\x0b\n\x03m12\x18\x07 \x01(\x02\x12\x0b\n\x03m13\x18\x08 \x01(\x02\x12\x0b\n\x03m20\x18\t \x01(\x02\x12\x0b\n\x03m21\x18\n \x01(\x02\x12\x0b\n\x03m22\x18\x0b \x01(\x02\x12\x0b\n\x03m23\x18\x0c \x01(\x02\x12\x0b\n\x03m30\x18\r \x01(\x02\x12\x0b\n\x03m31\x18\x0e \x01(\x02\x12\x0b\n\x03m32\x18\x0f \x01(\x02\x12\x0b\n\x03m33\x18\x10 \x01(\x02\"\x80\x01\n\tMatrix3x3\x12\x0b\n\x03m00\x18\x01 \x01(\x02\x12\x0b\n\x03m01\x18\x02 \x01(\x02\x12\x0b\n\x03m02\x18\x03 \x01(\x02\x12\x0b\n\x03m10\x18\x04 \x01(\x02\x12\x0b\n\x03m11\x18\x05 \x01(\x02\x12\x0b\n\x03m12\x18\x06 \x01(\x02\x12\x0b\n\x03m20\x18\x07 \x01(\x02\x12\x0b\n\x03m21\x18\x08 \x01(\x02\x12\x0b\n\x03m22\x18\t \x01(\x02\"\xd1\x02\n\x0b\x46rameUpdate\x12&\n\x04Head\x18\x01 \x01(\x0b\x32\x18.frametracking.Matrix4x4\x12+\n\tExtrinsic\x18\x02 \x01(\x0b\x32\x18.frametracking.Matrix4x4\x12+\n\tIntrinsic\x18\x03 \x01(\x0b\x32\x18.frametracking.Matrix3x3\x12\x13\n\x0b\x63\x61ptureTime\x18\x04 \x01(\x01\x12\x1c\n\x14midExposureTimestamp\x18\x05 \x01(\x05\x12\x18\n\x10\x63olorTemperature\x18\x06 \x01(\x05\x12\x18\n\x10\x65xposureDuration\x18\x07 \x01(\x01\x12\x12\n\ncameraType\x18\x08 \x01(\t\x12\x16\n\x0e\x63\x61meraPosition\x18\t \x01(\t\x12\r\n\x05image\x18\n \x01(\x0c\x12\x0f\n\x07seconds\x18\x0b \x01(\x03\x12\r\n\x05nanos\x18\x0c \x01(\x05\"!\n\x0e\x46rameUpdateAck\x12\x0f\n\x07message\x18\x01 \x01(\t2h\n\x14\x46rameTrackingService\x12P\n\x12streamFrameUpdates\x12\x1a.frametracking.FrameUpdate\x1a\x1a.frametracking.FrameUpdate\"\x00\x30\x01\x62\x06proto3')

_globals = globals()
_builder.BuildMessageAndEnumDescriptors(DESCRIPTOR, _globals)
_builder.BuildTopDescriptorsAndMessages(DESCRIPTOR, 'data_pb2', _globals)
if _descriptor._USE_C_DESCRIPTORS == False:
  DESCRIPTOR._options = None
  _globals['_MATRIX4X4']._serialized_start=30
  _globals['_MATRIX4X4']._serialized_end=249
  _globals['_MATRIX3X3']._serialized_start=252
  _globals['_MATRIX3X3']._serialized_end=380
  _globals['_FRAMEUPDATE']._serialized_start=383
  _globals['_FRAMEUPDATE']._serialized_end=720
  _globals['_FRAMEUPDATEACK']._serialized_start=722
  _globals['_FRAMEUPDATEACK']._serialized_end=755
  _globals['_FRAMETRACKINGSERVICE']._serialized_start=757
  _globals['_FRAMETRACKINGSERVICE']._serialized_end=861
# @@protoc_insertion_point(module_scope)
