// ############################################################################################
// intel_start_of_header
//
// INTEL CONFIDENTIAL
// Copyright 2018 Intel Corporation
//
// The source code contained or described herein and all documents related
// to the source code ("Material") are owned by Intel Corporation or
// its suppliers or licensors. Title to the Material remains with Intel
// Corporation or its suppliers and licensors. The Material contains trade
// secrets and proprietary and confidential information of Intel or its
// suppliers and licensors. The Material is protected by worldwide copyright
// and trade secret laws and treaty provisions. No part of the Material
// may be used, copied, reproduced, modified, published, uploaded, posted,
// transmitted, distributed, or disclosed in any way without Intel's prior
// express written permission.
//
// No license under any patent, copyright, trade secret or other intellectual
// property right is granted to or conferred upon you by disclosure or
// delivery of the Materials, either expressly, by implication, inducement,
// estoppel or otherwise. Any license under such intellectual property
// rights must be express and approved by Intel in writing.
//
// intel_end_of_header
// ############################################################################################
//--------------------------------------------------------------------------------------------
// Description: osc_ovs_pipe
// 
// Delay the input by a number of pipeline stages.
//
//--------------------------------------------------------------------------------------------

//-------------------------------------
// Configurable number of pipe stages
//-------------------------------------
module ipbb_pipe #(parameter W=1, N=2) (
  input var logic          clk,
  input var logic [W-1:0]  dIn,

  output logic [W-1:0] dOut
);

logic [W-1:0]   pipeT[N];

always @ (posedge clk) begin
  for (int i=0; i < N; i++) begin
    pipeT[i] <= (i == 0) ? dIn : pipeT[i-1];
  end
end

assign dOut = pipeT[N-1];

endmodule

