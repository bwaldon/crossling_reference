// Draft of sceneGenerator for quick testing:

 const scenes = [
  {
    "Name": "color_basic_target_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj1"
  },
  {
    "Name": "color_basic_filler_1_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj2"
  },
  {
    "Name": "color_basic_filler_2_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj3"
  },
  {
    "Name": "color_basic_filler_3_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj4"
  },
  {
    "Name": "color_basic_target_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj1"
  },
  {
    "Name": "color_basic_filler_1_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj2"
  },
  {
    "Name": "color_basic_filler_2_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj3"
  },
  {
    "Name": "color_basic_filler_3_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj4"
  },
  {
    "Name": "size_basic_target_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj1"
  },
  {
    "Name": "size_basic_filler_1_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj2"
  },
  {
    "Name": "size_basic_filler_2_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj3"
  },
  {
    "Name": "size_basic_filler_3_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj4"
  },
  {
    "Name": "size_basic_target_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj1"
  },
  {
    "Name": "size_basic_filler_1_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj2"
  },
  {
    "Name": "size_basic_filler_2_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj3"
  },
  {
    "Name": "size_basic_filler_3_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "",
    "Obj5_size": "",
    "Obj5_type": "",
    "Obj6_color": "",
    "Obj6_size": "",
    "Obj6_type": "",
    "Target": "Obj4"
  },
  {
    "Name": "color_same_diff_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_2",
    "Obj5_size": "size_2",
    "Obj5_type": "type_1",
    "Obj6_color": "color_2",
    "Obj6_size": "size_2",
    "Obj6_type": "type_1",
    "Target": "Obj1"
  },
  {
    "Name": "color_same_diff_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_2",
    "Obj5_size": "size_2",
    "Obj5_type": "type_1",
    "Obj6_color": "color_2",
    "Obj6_size": "size_2",
    "Obj6_type": "type_1",
    "Target": "Obj1"
  },
  {
    "Name": "color_same_same_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_1",
    "Obj5_size": "size_2",
    "Obj5_type": "type_1",
    "Obj6_color": "color_1",
    "Obj6_size": "size_2",
    "Obj6_type": "type_1",
    "Target": "Obj1"
  },
  {
    "Name": "color_same_same_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_1",
    "Obj5_size": "size_2",
    "Obj5_type": "type_1",
    "Obj6_color": "color_1",
    "Obj6_size": "size_2",
    "Obj6_type": "type_1",
    "Target": "Obj1"
  },
  {
    "Name": "color_diff_diff_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_2",
    "Obj5_size": "size_2",
    "Obj5_type": "type_2",
    "Obj6_color": "color_2",
    "Obj6_size": "size_2",
    "Obj6_type": "type_2",
    "Target": "Obj1"
  },
  {
    "Name": "color_diff_diff_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_2",
    "Obj5_size": "size_2",
    "Obj5_type": "type_2",
    "Obj6_color": "color_2",
    "Obj6_size": "size_2",
    "Obj6_type": "type_2",
    "Target": "Obj1"
  },
  {
    "Name": "color_diff_same_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_1",
    "Obj5_size": "size_2",
    "Obj5_type": "type_2",
    "Obj6_color": "color_1",
    "Obj6_size": "size_2",
    "Obj6_type": "type_2",
    "Target": "Obj1"
  },
  {
    "Name": "color_diff_same_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_1",
    "Obj2_size": "size_2",
    "Obj2_type": "type_1",
    "Obj3_color": "color_2",
    "Obj3_size": "size_1",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_1",
    "Obj5_size": "size_2",
    "Obj5_type": "type_2",
    "Obj6_color": "color_1",
    "Obj6_size": "size_2",
    "Obj6_type": "type_2",
    "Target": "Obj1"
  },
  {
    "Name": "size_same_diff_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_2",
    "Obj5_size": "size_2",
    "Obj5_type": "type_1",
    "Obj6_color": "color_2",
    "Obj6_size": "size_2",
    "Obj6_type": "type_1",
    "Target": "Obj1"
  },
  {
    "Name": "size_same_diff_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_2",
    "Obj5_size": "size_2",
    "Obj5_type": "type_1",
    "Obj6_color": "color_2",
    "Obj6_size": "size_2",
    "Obj6_type": "type_1",
    "Target": "Obj1"
  },
  {
    "Name": "size_same_same_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_2",
    "Obj5_size": "size_1",
    "Obj5_type": "type_1",
    "Obj6_color": "color_2",
    "Obj6_size": "size_1",
    "Obj6_type": "type_1",
    "Target": "Obj1"
  },
  {
    "Name": "size_same_same_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_2",
    "Obj5_size": "size_1",
    "Obj5_type": "type_1",
    "Obj6_color": "color_2",
    "Obj6_size": "size_1",
    "Obj6_type": "type_1",
    "Target": "Obj1"
  },
  {
    "Name": "size_diff_diff_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_2",
    "Obj5_size": "size_2",
    "Obj5_type": "type_2",
    "Obj6_color": "color_2",
    "Obj6_size": "size_2",
    "Obj6_type": "type_2",
    "Target": "Obj1"
  },
  {
    "Name": "size_diff_diff_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_2",
    "Obj5_size": "size_2",
    "Obj5_type": "type_2",
    "Obj6_color": "color_2",
    "Obj6_size": "size_2",
    "Obj6_type": "type_2",
    "Target": "Obj1"
  },
  {
    "Name": "size_diff_same_f",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_2",
    "Obj5_size": "size_1",
    "Obj5_type": "type_2",
    "Obj6_color": "color_2",
    "Obj6_size": "size_1",
    "Obj6_type": "type_2",
    "Target": "Obj1"
  },
  {
    "Name": "size_diff_same_m",
    "Obj1_color": "color_1",
    "Obj1_size": "size_1",
    "Obj1_type": "type_1",
    "Obj2_color": "color_2",
    "Obj2_size": "size_1",
    "Obj2_type": "type_1",
    "Obj3_color": "color_1",
    "Obj3_size": "size_2",
    "Obj3_type": "type_2",
    "Obj4_color": "color_2",
    "Obj4_size": "size_2",
    "Obj4_type": "type_1",
    "Obj5_color": "color_2",
    "Obj5_size": "size_1",
    "Obj5_type": "type_2",
    "Obj6_color": "color_2",
    "Obj6_size": "size_1",
    "Obj6_type": "type_2",
    "Target": "Obj1"
  }
]
 const femAll = ["fork", "key", "remote","belt","candle","calculator","cap","chair","clock","crown", "tie"
, "tent", "spoon", "sock", "shovel", "scarf", "ruler", "ring", "ornament", "napkin", "mug", "mouse", "lamp", "fryingpan",
"flower","guitar", "dress", "door", //rest are exclusive to french
"billiardball", "magnifyingglass", "stapler", "ladle"]

const mascAll = ["airplane", "bike", "comb", "armchair", "screwdriver",
"balloon", "bed","bonbon","bucket","butterfly","cake", "calendar","coathanger","cushion"
,"die", "drum","fish","frame","hammer","knife","lipstick","lock","mask","microscope","pencil","phone"
,"present","piano","whistle", "truck", "vase", "switch", "shell", "robot", "razor", "rug"]

const nounToScheme = {
"airplane" : 0, "bike" : 1, "comb" : 1, "armchair" : 1,
"balloon": 1, "bed": 1,"bonbon":0,"bucket":1,"butterfly": 1,
"cake" : 0, "calendar" : 0,"coathanger": 1,"cushion":1,
"die": 0, "drum" : 0,"fish": 0,"frame":1 ,"hammer": 0,"knife": 0,
"lipstick": 0,"lock": 0,"mask":1,"microscope": 0,"pencil": 1,"phone": 1
,"present": 1,"piano": 0,"whistle":0, "truck":0, "vase": 0, "switch":1,
"shell": 0, "robot": 0, "razor": 0, "rug":1,
"fork": 0, "key":1, "remote":0,"belt":1,"candle":1,"calculator":1,"cap":1,
"chair":1,"clock":1,"crown":1, "tie":0,
"tent": 0, "spoon":0, "sock":0, "shovel":0, "scarf":1, "ruler":1, "ring":1,
"ornament":1, "napkin":1, "mug":1, "mouse":1, "lamp":1, "fryingpan":1,
"flower":1,"guitar":1, "dress":1, "door":1, //rest are exclusive to french
"billiardball":1, "magnifyingglass":1, "stapler":1, "ladle":0, "screwdriver": 0
}

const colorPool = [["green", "orange", "purple", "black"],["red", "yellow",  "blue", "white"]]
//scheme 1: green, orange, purple, black
//scheme 2: blue, red, white, yellow

//picks a random noun from an array
function pickNoun(pool) {
    noun = pool[Math.floor(Math.random() * pool.length)];
    //TODO remove noun from list
  return noun
}
function pickNounScheme(pool, scheme){
  poolSchemeMatch = pool.filter(x => nounToScheme[x] == scheme)
  console.log(poolSchemeMatch)
  return(pickNoun(poolSchemeMatch))
}
//selects a random color and another different color
function pickColor(scheme) {
  return colorPool[scheme][Math.floor(Math.random() * colorPool[scheme].length)];
}
function pickColorExcept(color, scheme) {
  newPool = colorPool[scheme].filter(x => x != color)
  return newPool[Math.floor(Math.random() * newPool.length)];
}
function getScheme(noun){
  return nounToScheme[noun]
}

//assign colors, sizes and types to the objects in the template
function fillScenes(sceneTemplate) {
  newScenes = []
  femPool = femAll
  mascPool = mascAll
  for (index in sceneTemplate) {
    sceneName = sceneTemplate[index]["Name"]
    // pick values
    type_1 = sceneName.includes("_m")? pickNoun(mascPool) : pickNoun(femPool)
    mascPool = mascPool.filter(x => x != type_1)//no replacement
    femPool = femPool.filter(x => x != type_1)
    scheme1 = getScheme(type_1)
    type_2 = sceneName.includes("_m")? pickNounScheme(mascPool,scheme1) : pickNounScheme(femPool,scheme1)
    mascPool = mascPool.filter(x => x != type_2)//no replacement
    femPool = femPool.filter(x =>  x != type_2)
    // pick color: nouns come in 4 of 8 colors according to the specific color scheme to which they belong
    color_1 = pickColor(scheme1)
    color_2 = pickColorExcept(color_1, scheme1)
    //Exactly half of the trials have small targets and half have big targets
    size_1 = index%2 == 0? "small" : "big"
    size_2 = index%2 == 1? "small" : "big"
    // assign the values
    sceneString = JSON.stringify(sceneTemplate[index])
    sceneString = sceneString.replace(/color_1/g, color_1)
    sceneString = sceneString.replace(/color_2/g, color_2)
    sceneString = sceneString.replace(/size_1/g, size_1)
    sceneString = sceneString.replace(/size_2/g, size_2)
    sceneString = sceneString.replace(/type_1/g, type_1)
    sceneString = sceneString.replace(/type_2/g, type_2)
    //revert to Json and push new scene
    sceneToAdd = JSON.parse(sceneString)
    newScenes.push(sceneToAdd)
  }
  //newScenes = _.shuffle(newScenes) --> does not work without importing the _ library in other files
  return(newScenes)
}
// creating scenes as a list of object paths to image files
function makePaths(objectList){
  newScenes = []
  for (index in objectList){
    scene = objectList[index]
    Objnew = {"condition" : scene["Name"], "imageType" : "NA"}
    numAlt = 1
    for (let i = 1 ; i < 7 ; i ++){
      nameOrig = "Obj" + i
      path = scene[nameOrig+"_color"]+"_"+scene[nameOrig+"_type"]
      if (nameOrig == scene["Target"]) {
        nameNew = "TargetItem"
      } else {
        nameNew = "alt"+numAlt
        numAlt += 1
      }
      if (nameNew != "TargetItem") {
        Objnew[nameNew+"Name"] = path != "_"? path : "IGNORE"
      } else{
        Objnew[nameNew] = path != "_"? path : "IGNORE"
      }
      Objnew[nameNew+"Size"] = scene[nameOrig+"_size"]
    }
    newScenes.push(Objnew)
  }
  return(newScenes)
}


  newScenes = fillScenes(scenes)
  scenePaths = makePaths(newScenes)
