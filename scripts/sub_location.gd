# sub_location.gd - 子地點資源類
class_name SubLocation
extends Resource

## 子地點唯一ID
@export var sub_location_id: String = ""

## 子地點名稱（如"茶館"、"客棧"）
@export var sub_location_name: String = ""

## 子地點描述
@export var description: String = ""

## 可用條件（可選）
@export var available_conditions: Array[EventCondition] = []

## 可選動作列表
@export var actions: Array[LocationAction] = []

## 子地點圖片路徑（可選）
@export var illustration_path: String = ""
