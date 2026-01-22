# location_data.gd - 地點資源類
class_name LocationData
extends Resource

## 地點唯一ID
@export var location_id: String = ""

## 地點名稱
@export var location_name: String = ""

## 地點描述
@export var description: String = ""

## 可用條件（可選）
@export var available_conditions: Array[EventCondition] = []

## 子地點列表（如"茶館"、"客棧"）
@export var sub_locations: Array[SubLocation] = []

## 地點圖片路徑（可選，將來用於視覺升級）
@export var illustration_path: String = ""
