//*************************************************************//
//   ** File Generated Automatically
//   ** Please donot edit manually
//*************************************************************//


package apb_wrapper_reg_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import cdns_uvmreg_utils_pkg::*;

  bit no_factory = 0; 

/////////////////////////////////////////////////////
//                EB_COR_CFG_MAX
/////////////////////////////////////////////////////
class T_EB_COR_CFG_MAX_15 extends cdns_uvm_reg;

  `uvm_object_utils(T_EB_COR_CFG_MAX_15)
  rand uvm_reg_field cor_max;
  
  covergroup wr_fld_covg;
    cor_max: coverpoint cor_max.value[5:0];
  endgroup
  covergroup rd_fld_covg;
    cor_max: coverpoint cor_max.value[5:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    cor_max = fld_set[0];
  endfunction

  function new(input string name="T_EB_COR_CFG_MAX_15");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                EB_COR_CFG_MIN
/////////////////////////////////////////////////////
class T_EB_COR_CFG_MIN_16 extends cdns_uvm_reg;

  `uvm_object_utils(T_EB_COR_CFG_MIN_16)
  rand uvm_reg_field cor_min;
  
  covergroup wr_fld_covg;
    cor_min: coverpoint cor_min.value[5:0];
  endgroup
  covergroup rd_fld_covg;
    cor_min: coverpoint cor_min.value[5:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    cor_min = fld_set[0];
  endfunction

  function new(input string name="T_EB_COR_CFG_MIN_16");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                EB_COR_SEQ1
/////////////////////////////////////////////////////
class T_EB_COR_SEQ1_17 extends cdns_uvm_reg;

  `uvm_object_utils(T_EB_COR_SEQ1_17)
  rand uvm_reg_field cor_seq1;
  
  covergroup wr_fld_covg;
    cor_seq1: coverpoint cor_seq1.value[19:0];
  endgroup
  covergroup rd_fld_covg;
    cor_seq1: coverpoint cor_seq1.value[19:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    cor_seq1 = fld_set[0];
  endfunction

  function new(input string name="T_EB_COR_SEQ1_17");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                EB_COR_SEQ2
/////////////////////////////////////////////////////
class T_EB_COR_SEQ2_18 extends cdns_uvm_reg;

  `uvm_object_utils(T_EB_COR_SEQ2_18)
  rand uvm_reg_field cor_seq2;
  
  covergroup wr_fld_covg;
    cor_seq2: coverpoint cor_seq2.value[19:0];
  endgroup
  covergroup rd_fld_covg;
    cor_seq2: coverpoint cor_seq2.value[19:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    cor_seq2 = fld_set[0];
  endfunction

  function new(input string name="T_EB_COR_SEQ2_18");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                EB_CTRL
/////////////////////////////////////////////////////
class T_EB_CTRL_14 extends cdns_uvm_reg;

  `uvm_object_utils(T_EB_CTRL_14)
  rand uvm_reg_field enable;
  
  covergroup wr_fld_covg;
    enable: coverpoint enable.value[0:0];
  endgroup
  covergroup rd_fld_covg;
    enable: coverpoint enable.value[0:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    enable = fld_set[0];
  endfunction

  function new(input string name="T_EB_CTRL_14");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                EB_ERR_STATUS
/////////////////////////////////////////////////////
class T_EB_ERR_STATUS_23 extends cdns_uvm_reg;

  `uvm_object_utils(T_EB_ERR_STATUS_23)
  rand uvm_reg_field err_status;
  
  covergroup wr_fld_covg;
    err_status: coverpoint err_status.value[2:0];
  endgroup
  covergroup rd_fld_covg;
    err_status: coverpoint err_status.value[2:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    err_status = fld_set[0];
  endfunction

  function new(input string name="T_EB_ERR_STATUS_23");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                EB_FILL_LEVEL
/////////////////////////////////////////////////////
class T_EB_FILL_LEVEL_19 extends cdns_uvm_reg;

  `uvm_object_utils(T_EB_FILL_LEVEL_19)
  rand uvm_reg_field fill_level;
  
  covergroup wr_fld_covg;
    fill_level: coverpoint fill_level.value[5:0];
  endgroup
  covergroup rd_fld_covg;
    fill_level: coverpoint fill_level.value[5:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    fill_level = fld_set[0];
  endfunction

  function new(input string name="T_EB_FILL_LEVEL_19");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                EB_SKP_ADD_CNT
/////////////////////////////////////////////////////
class T_EB_SKP_ADD_CNT_20 extends cdns_uvm_reg;

  `uvm_object_utils(T_EB_SKP_ADD_CNT_20)
  rand uvm_reg_field skp_add_cnt;
  
  covergroup wr_fld_covg;
    skp_add_cnt: coverpoint skp_add_cnt.value[15:0];
  endgroup
  covergroup rd_fld_covg;
    skp_add_cnt: coverpoint skp_add_cnt.value[15:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    skp_add_cnt = fld_set[0];
  endfunction

  function new(input string name="T_EB_SKP_ADD_CNT_20");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                EB_SKP_EVENT
/////////////////////////////////////////////////////
class T_EB_SKP_EVENT_22 extends cdns_uvm_reg;

  `uvm_object_utils(T_EB_SKP_EVENT_22)
  rand uvm_reg_field skp_drop_evt;
  rand uvm_reg_field skp_add_evt;
  
  covergroup wr_fld_covg;
    skp_drop_evt: coverpoint skp_drop_evt.value[0:0];
    skp_add_evt: coverpoint skp_add_evt.value[0:0];
  endgroup
  covergroup rd_fld_covg;
    skp_drop_evt: coverpoint skp_drop_evt.value[0:0];
    skp_add_evt: coverpoint skp_add_evt.value[0:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    skp_drop_evt = fld_set[0];
    skp_add_evt = fld_set[1];
  endfunction

  function new(input string name="T_EB_SKP_EVENT_22");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                EB_SKP_RM_CNT
/////////////////////////////////////////////////////
class T_EB_SKP_RM_CNT_21 extends cdns_uvm_reg;

  `uvm_object_utils(T_EB_SKP_RM_CNT_21)
  rand uvm_reg_field skp_rm_cnt;
  
  covergroup wr_fld_covg;
    skp_rm_cnt: coverpoint skp_rm_cnt.value[15:0];
  endgroup
  covergroup rd_fld_covg;
    skp_rm_cnt: coverpoint skp_rm_cnt.value[15:0];
  endgroup

  protected virtual function void sample(uvm_reg_data_t data, uvm_reg_data_t byte_en, bit is_read, uvm_reg_map map);
    super.sample(data, byte_en, is_read, map);
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      if(!is_read) begin
          wr_fld_covg.sample();
      end
      if(is_read) begin
          rd_fld_covg.sample();
      end
    end
  endfunction

  virtual function void sample_values();
    super.sample_values();
    if (get_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg.sample();
      rd_fld_covg.sample();
    end
  endfunction

  virtual function void build();
    uvm_reg_field fld_set[$];
    uvm_reg_field_config_ta ta = get_field_config(getconfigUID());
    build_uvm_reg_fields(this, ta, fld_set);
    
    skp_rm_cnt = fld_set[0];
  endfunction

  function new(input string name="T_EB_SKP_RM_CNT_21");
    super.new(name, 32, build_coverage(UVM_CVR_FIELD_VALS));
    if (has_coverage(UVM_CVR_FIELD_VALS)) begin
      wr_fld_covg = new();
      rd_fld_covg = new();
    end
  endfunction

endclass


/////////////////////////////////////////////////////
//                apb_map_eb_regs
/////////////////////////////////////////////////////
class T_eb_regs_24 extends cdns_uvm_reg_block;

  `uvm_object_utils(T_eb_regs_24)
  rand T_EB_COR_CFG_MAX_15 EB_COR_CFG_MAX;
  rand T_EB_COR_CFG_MIN_16 EB_COR_CFG_MIN;
  rand T_EB_COR_SEQ1_17 EB_COR_SEQ1;
  rand T_EB_COR_SEQ2_18 EB_COR_SEQ2;
  rand T_EB_CTRL_14 EB_CTRL;
  rand T_EB_ERR_STATUS_23 EB_ERR_STATUS;
  rand T_EB_FILL_LEVEL_19 EB_FILL_LEVEL;
  rand T_EB_SKP_ADD_CNT_20 EB_SKP_ADD_CNT;
  rand T_EB_SKP_EVENT_22 EB_SKP_EVENT;
  rand T_EB_SKP_RM_CNT_21 EB_SKP_RM_CNT;



  virtual function void build();
    uvm_reg  reg_set[$];
    string config_path = get_hier_path();
    default_map = create_map(get_name(), `UVM_REG_ADDR_WIDTH'hA0000000, 4, UVM_LITTLE_ENDIAN, 1);
    begin
       uvm_reg_config_ta ta = get_reg_config({"elastic_buffer_apb_regs", config_path});
       build_uvm_regs(default_map, this, null, ta, reg_set);
    end
    if(! $cast(EB_COR_CFG_MAX, reg_set[0]))
      `uvm_error("UVM_REG", "EB_COR_CFG_MAX register casting error")
    if(! $cast(EB_COR_CFG_MIN, reg_set[1]))
      `uvm_error("UVM_REG", "EB_COR_CFG_MIN register casting error")
    if(! $cast(EB_COR_SEQ1, reg_set[2]))
      `uvm_error("UVM_REG", "EB_COR_SEQ1 register casting error")
    if(! $cast(EB_COR_SEQ2, reg_set[3]))
      `uvm_error("UVM_REG", "EB_COR_SEQ2 register casting error")
    if(! $cast(EB_CTRL, reg_set[4]))
      `uvm_error("UVM_REG", "EB_CTRL register casting error")
    if(! $cast(EB_ERR_STATUS, reg_set[5]))
      `uvm_error("UVM_REG", "EB_ERR_STATUS register casting error")
    if(! $cast(EB_FILL_LEVEL, reg_set[6]))
      `uvm_error("UVM_REG", "EB_FILL_LEVEL register casting error")
    if(! $cast(EB_SKP_ADD_CNT, reg_set[7]))
      `uvm_error("UVM_REG", "EB_SKP_ADD_CNT register casting error")
    if(! $cast(EB_SKP_EVENT, reg_set[8]))
      `uvm_error("UVM_REG", "EB_SKP_EVENT register casting error")
    if(! $cast(EB_SKP_RM_CNT, reg_set[9]))
      `uvm_error("UVM_REG", "EB_SKP_RM_CNT register casting error")

  endfunction

  function new(input string name="apb_map_eb_regs");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

endclass


/////////////////////////////////////////////////////
//                elastic_buffer_apb_regs
/////////////////////////////////////////////////////
class elastic_buffer_apb_regs_vendor_mohamed_tarek_library_flat_version_1_0 extends cdns_uvm_reg_block;

  `uvm_object_utils(elastic_buffer_apb_regs_vendor_mohamed_tarek_library_flat_version_1_0)

  uvm_reg_map default_map;
  uvm_reg_map apb_map;
  rand T_eb_regs_24 apb_map_eb_regs;

  virtual function void build();
    apb_map = create_map("apb_map", `UVM_REG_ADDR_WIDTH'h0, 4, UVM_LITTLE_ENDIAN, 1);
    default_map = apb_map;
    apb_map_eb_regs = T_eb_regs_24::type_id::create("apb_map_eb_regs", , get_full_name());
    apb_map_eb_regs.configure(this);
    apb_map_eb_regs.build();

    //Mapping apb_map map
    apb_map_eb_regs.default_map.add_parent_map(apb_map,`UVM_REG_ADDR_WIDTH'hA0000000);
    apb_map.set_submap_offset(apb_map_eb_regs.default_map, `UVM_REG_ADDR_WIDTH'hA0000000);
    //Apply hdl_paths
    apply_hdl_paths(this);

  endfunction



  function new(input string name="elastic_buffer_apb_regs");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

endclass

//This typedef is defined for user-defined top level class name
typedef elastic_buffer_apb_regs_vendor_mohamed_tarek_library_flat_version_1_0 apb_wrapper_regs_t;


//*************************************************//
//Factory Methods
//*************************************************//
class reg_verifier_factory extends cdns_factory_base;
   virtual function uvm_object create(string typename, string pathname,string objectname);
      case(typename)
         "T_EB_COR_CFG_MAX_15": begin T_EB_COR_CFG_MAX_15 EB_COR_CFG_MAX = new(objectname); create = EB_COR_CFG_MAX;  end
         "T_EB_COR_CFG_MIN_16": begin T_EB_COR_CFG_MIN_16 EB_COR_CFG_MIN = new(objectname); create = EB_COR_CFG_MIN;  end
         "T_EB_COR_SEQ1_17": begin T_EB_COR_SEQ1_17 EB_COR_SEQ1 = new(objectname); create = EB_COR_SEQ1;  end
         "T_EB_COR_SEQ2_18": begin T_EB_COR_SEQ2_18 EB_COR_SEQ2 = new(objectname); create = EB_COR_SEQ2;  end
         "T_EB_CTRL_14": begin T_EB_CTRL_14 EB_CTRL = new(objectname); create = EB_CTRL;  end
         "T_EB_ERR_STATUS_23": begin T_EB_ERR_STATUS_23 EB_ERR_STATUS = new(objectname); create = EB_ERR_STATUS;  end
         "T_EB_FILL_LEVEL_19": begin T_EB_FILL_LEVEL_19 EB_FILL_LEVEL = new(objectname); create = EB_FILL_LEVEL;  end
         "T_EB_SKP_ADD_CNT_20": begin T_EB_SKP_ADD_CNT_20 EB_SKP_ADD_CNT = new(objectname); create = EB_SKP_ADD_CNT;  end
         "T_EB_SKP_EVENT_22": begin T_EB_SKP_EVENT_22 EB_SKP_EVENT = new(objectname); create = EB_SKP_EVENT;  end
         "T_EB_SKP_RM_CNT_21": begin T_EB_SKP_RM_CNT_21 EB_SKP_RM_CNT = new(objectname); create = EB_SKP_RM_CNT;  end

      endcase
   endfunction
endclass


//get_factory() function to select the factory
function automatic cdns_factory_base get_factory(bit no_factory);
   static cdns_factory_base factory;
   if(factory == null) begin
      if(no_factory == 1) begin
         reg_verifier_factory rv_factory = new;
         factory = rv_factory;
      end
      else begin
         uvm_factory_proxy rv_factory = new;
         factory = rv_factory;
      end
   end
   cdns_uvmreg_utils_pkg::factory=factory;


   return factory;
endfunction
cdns_factory_base factory = get_factory(no_factory);

endpackage



