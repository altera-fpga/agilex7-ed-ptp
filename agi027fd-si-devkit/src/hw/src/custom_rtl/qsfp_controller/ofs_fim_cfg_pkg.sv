// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// This package defines the global parameters of FIM
//
//----------------------------------------------------------------------------

`ifndef __OFS_FIM_CFG_PKG_SV__
`define __OFS_FIM_CFG_PKG_SV__

package ofs_fim_cfg_pkg;


//*****************
// PCIe host parameters
//*****************
`ifdef SIM_USE_PCIE_GEN3X16_BFM
   localparam PCIE_LANES = 16; 
`else
   localparam PCIE_LANES = 16;
`endif

localparam NUM_PCIE_HOST      = 1;
localparam PCIE_HOST_WIDTH    = $clog2(NUM_PCIE_HOST);

localparam PCIE_TDATA_WIDTH  = 512;
localparam PCIE_TUSER_WIDTH  = 10;

localparam PCIE_RP_MAX_TAGS   = (1<<10);
localparam PCIE_RP_TAG_WIDTH  = $clog2(PCIE_RP_MAX_TAGS);

localparam MAX_PAYLOAD_SIZE   = 128; // DW
localparam MAX_RD_REQ_SIZE    = 128; // DW

//*****************
// MMIO parameters
//*****************
localparam PORTS              = 1;
localparam MMIO_TID_WIDTH     = PCIE_HOST_WIDTH + PCIE_RP_TAG_WIDTH; // Matches PCIe TLP tag width 
localparam MMIO_DATA_WIDTH    = 64;
localparam MMIO_ADDR_WIDTH    = 20; // PF0 bar 0 addr width 1MB, VF under this PF has same address width
localparam NONPF0_MMIO_ADDR_WIDTH      = 12; // non PF0 bar 0 addr width 4KB


//MSIX
`ifdef NUM_AFUS
localparam   NUM_AFUS    = 2;
`else
localparam   NUM_AFUS    = 1;
`endif
localparam LNUM_AFUS = NUM_AFUS>1?$clog2(NUM_AFUS):1'h1;
localparam NUM_AFU_INTERRUPTS = 7;
localparam L_NUM_AFU_INTERRUPTS = $clog2(NUM_AFU_INTERRUPTS);

//*****************
// DFH parameters
//*****************

localparam DUMMY_HSSI_DFH_NEXT_OFFSET  = 24'h1000;
localparam DUMMY_HSSI_DFH_EOL          = 1'h0;
localparam DUMMY_QSFP0_DFH_NEXT_OFFSET = 24'h1000;
localparam DUMMY_QSFP0_DFH_EOL         = 1'h0;
localparam DUMMY_QSFP1_DFH_NEXT_OFFSET = 24'h1000;
localparam DUMMY_QSFP1_DFH_EOL         = 1'h0;

localparam HSSI_DFH_NEXT_OFFSET  = 24'h1000;
localparam HSSI_DFH_EOL          = 1'h0;
localparam QSFP0_DFH_NEXT_OFFSET = 24'h1000;
localparam QSFP0_DFH_EOL         = 1'h0;
localparam QSFP1_DFH_NEXT_OFFSET = 24'h1000;
localparam QSFP1_DFH_EOL         = 1'h0;

`ifdef ENABLE_APF_HPS 
  localparam FME_DFH_NEXT_OFFSET       = 24'h10000 + QSFP0_DFH_NEXT_OFFSET + QSFP1_DFH_NEXT_OFFSET + HSSI_DFH_NEXT_OFFSET ;
`else
  localparam FME_DFH_NEXT_OFFSET       = 24'h10000;
`endif

localparam PCIE_DFH_NEXT_OFFSET = 24'h2000;
localparam PCIE_DFH_EOL         = 1'h0;

localparam PMCI_DFH_NEXT_OFFSET = 24'h20000;
localparam PMCI_DFH_EOL         = 1'h0;

localparam DUMMY_PMCI_DFH_NEXT_OFFSET = 24'h20000;
localparam DUMMY_PMCI_DFH_EOL         = 1'h0;

localparam MSS_DFH_NEXT_OFFSET = 24'h0000;
localparam MSS_DFH_EOL         = 1'h0;

localparam DUMMY_MSS_DFH_NEXT_OFFSET = 24'h0000;
localparam DUMMY_MSS_DFH_EOL         = 1'h0;

localparam EMIF_DFH_NEXT_OFFSET = 24'hB000;
localparam EMIF_DFH_EOL         = 1'h0;

localparam DUMMY_EMIF_DFH_NEXT_OFFSET = 24'hB000;
localparam DUMMY_EMIF_DFH_EOL         = 1'h0;

localparam DUMMY_TOD_DFH_NEXT_OFFSET = 24'h10000;
localparam DUMMY_TOD_DFH_EOL         = 1'h0;

localparam TOD_DFH_NEXT_OFFSET = 24'h10000;
localparam TOD_DFH_EOL         = 1'h0;

localparam PG_DFH_NEXT_OFFSET = 24'h10000;
localparam PG_DFH_EOL         = 1'h0;


endpackage

`endif // __OFS_FIM_CFG_PKG_SV__
