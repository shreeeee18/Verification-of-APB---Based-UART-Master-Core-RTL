class uart_sb extends uvm_scoreboard;
	
	uart_env_config e_cfg;
	
	uvm_tlm_analysis_fifo #(uart_xtn) fifo_h[];

	uart_xtn uart1, uart2;
		
	int success, failed;
		
	`uvm_component_utils(uart_sb)
	
	covergroup uartt1;
		PRESETN: coverpoint uart1.Presetn {bins Presetn = {[0:1]};} 		
		PADDR: 	coverpoint uart1.Paddr {bins Paddr = {[0:$]};} 		
		PWDATA: 	coverpoint uart1.Pwdata {bins Pwdata = {[0:$]};} 		
		PWRITE: 	coverpoint uart1.Pwrite {bins Pwrite = {[0:1]};} 		
		PENABLE: coverpoint uart1.Penable {bins Penable = {[0:1]};} 		
		PSEL: 	coverpoint uart1.Psel {bins Psel = {[0:1]};} 		
		PRDATA: 	coverpoint uart1.Prdata {bins Prdata = {[0:$]};} 		
		PREADY: 	coverpoint uart1.Pready {bins Pready = {[0:1]};} 
		PSLVERR: coverpoint uart1.Pslverr {bins Pslverr = {[0:1]};} 
		IRQ: 		coverpoint uart1.IRQ {bins IRQ = {[0:1]};} 		
		BAUD: 	coverpoint uart1.baud_o {bins baud_o = {[0:1]};} 
	endgroup

	covergroup uartt2;
		PRESETN: coverpoint uart2.Presetn {bins Presetn = {[0:1]};} 		
		PADDR: 	coverpoint uart2.Paddr {bins Paddr = {[0:$]};} 		
		PWDATA: 	coverpoint uart2.Pwdata {bins Pwdata = {[0:$]};} 		
		PWRITE: 	coverpoint uart2.Pwrite {bins Pwrite = {[0:1]};} 		
		PENABLE: coverpoint uart2.Penable {bins Penable = {[0:1]};} 		
		PSEL: 	coverpoint uart2.Psel {bins Psel = {[0:1]};} 		
		PRDATA: 	coverpoint uart2.Prdata {bins Prdata = {[0:$]};} 		
		PSLVERR: coverpoint uart2.Pslverr {bins Pslverr = {[0:1]};} 
		PREADY: 	coverpoint uart2.Pready {bins Pready = {[0:1]};} 		
		IRQ: 		coverpoint uart2.IRQ {bins IRQ = {[0:1]};} 		
		BAUD: 	coverpoint uart2.baud_o {bins baud_o = {[0:1]};} 
	endgroup
	
	
	covergroup UART1_REGISTER;
		DIV1_MSB:  coverpoint uart1.DIV1 {bins DIV1 = {32'h0,32'h1};}
		DIV2_LSB:  coverpoint uart1.DIV2 {bins DIV2 = {32'd54, 32'd27};}
		FCR     :  coverpoint uart1.FCR  {bins FCR = {8'b00000110, 8'b11000110, 8'b10000110};}
		IER     :  coverpoint uart1.IER  {bins IER = {8'b00000101, 8'b00000100, 8'b00000010, 8'b00000000};}
		LCR     :  coverpoint uart1.LCR  {bins LCR = {8'b00000011, 8'b00001011, 8'b01000011};}
		THR     :  coverpoint uart1.THR[$]  {bins TXD = {[1:255]};}
		IIR     :  coverpoint uart1.IIR[3:0]  {bins IIR[] = {4'h4, 4'h6};}
		MCR     :  coverpoint uart1.MCR  {bins MCR = {8'b00010000};}
	endgroup

	covergroup UART2_REGISTER;
		DIV1_MSB:  coverpoint uart2.DIV1 {bins DIV1 = {32'h0,32'h1};}
		DIV2_LSB:  coverpoint uart2.DIV2 {bins DIV2 = {32'd54, 32'd27};}
		FCR     :  coverpoint uart2.FCR  {bins FCR = {8'b00000110, 8'b11000110, 8'b10000110};}
		IER     :  coverpoint uart2.IER  {bins IER = {8'b00000101, 8'b00000100, 8'b00000010, 8'b00000000};}
		LCR     :  coverpoint uart2.LCR  {bins LCR = {8'b00000011, 8'b00001011, 8'b01000011};}
		THR     :  coverpoint uart2.THR[$]  {bins TXD = {[1:255]};}
		IIR     :  coverpoint uart2.IIR[3:0]  {bins IIR[] = {4'h4,4'h6};}
		MCR     :  coverpoint uart2.MCR  {bins MCR = {8'b00010000};}
	endgroup


	
			
	
	function new (string name = "uart_sb", uvm_component parent);	
		super.new(name, parent);
		UART2_REGISTER = new;
		UART1_REGISTER = new;
		uartt1 = new;
		uartt2 = new;
			
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(uart_env_config)::get(this, "", "uart_env_config", e_cfg))
			`uvm_fatal("sb", "config failed")
			fifo_h =new[e_cfg.no_of_uart_agents];
			foreach(fifo_h[i])
             begin
                fifo_h[i] = new($sformatf("fifo_h[%0d]",i), this);
             end
	endfunction
	
	task run_phase(uvm_phase phase);
				fork
					forever 
					begin
						fifo_h[0].get(uart1);
						//uart1.print;
					end
				
					forever 
					begin
						fifo_h[1].get(uart2);
						//uart2.print;
					end
				join
	endtask
	
	function void compare(uart_xtn uart1, uart_xtn uart2);
		if((uart1.THR == uart2.RBR) && (uart2.THR == uart1.RBR))
				success++;
		else	
				failed++;
	endfunction

	function void check_phase (uvm_phase phase);
		super.check_phase(phase);
		$display("======================================");
		foreach(uart1.THR[i])
			$display($sformatf("value sent by uart1 is:[%0d]",i),uart1.THR[i]);

		foreach(uart2.RBR[i])
			$display($sformatf("value received by uart2 is:[%0d]",i),uart2.RBR[i]);
		$display("======================================\n");

		$display("======================================");
		foreach(uart2.THR[i])
			$display($sformatf("value sent by uart2 is:[%0d]",i),uart2.THR[i]);

		foreach(uart1.RBR[i])
			$display($sformatf("value received by uart1 is:[%0d]",i),uart1.RBR[i]);
		$display("======================================\n");
		
		$display("=================================================UART 1 REGISTERS============================================");
		$display("value of IER is :%p",uart1.IER);
		$display("value of IIR is :%p",uart1.IIR);
		$display("value of FCR is :%p",uart1.FCR);
		$display("value of MCR is :%p",uart1.MCR);
		$display("value of LCR is :%p",uart1.LCR);
		$display("value of LSR is :%p",uart1.LSR);
		$display("value of MSR is :%p",uart1.MSR);
		$display("value of DIV1 is :%p",uart1.DIV1);
		$display("value of DIV2 is :%p",uart1.DIV2);
		$display("============================================================================================================\n");
		
		$display("=================================================UART 2 REGISTERS============================================");
		$display("value of IER is :%p",uart2.IER);
		$display("value of IIR is :%p",uart2.IIR);
		$display("value of FCR is :%p",uart2.FCR);
		$display("value of MCR is :%p",uart2.MCR);
		$display("value of LCR is :%p",uart2.LCR);
		$display("value of LSR is :%p",uart2.LSR);
		$display("value of MSR is :%p",uart2.MSR);
		$display("value of DIV1 is :%p",uart2.DIV1);
		$display("value of DIV2 is :%p",uart2.DIV2);
		$display("============================================================================================================\n");
		
		
			begin
				if((uart1.THR.size != 0 && uart1.THR == uart2.RBR) && (uart2.THR.size != 0 && uart2.THR == uart1.RBR)) begin
					compare(uart1, uart2);
					`uvm_info("Score_Board", "FULL DUPLEX SUCCESSFULLY COMPARED", UVM_LOW)
				end			
				else if((uart1.THR.size != 0 && uart1.THR == uart2.RBR) || (uart2.THR.size != 0 && uart2.THR == uart1.RBR)) begin
					compare(uart1, uart2);
					`uvm_info("Score_Board", "HALF DUPLEX SUCCESSFULLY COMPARED", UVM_LOW)	
				end				
				else
					begin
						if((uart1.THR.size != 0 && uart1.THR == uart1.RBR) || (uart2.THR.size != 0 && uart2.THR == uart2.RBR)) begin
							success++;
							`uvm_info("Score_Board", "LOOPBACK COMPARED", UVM_LOW)
						end
					end
			end

		if((uart1.IIR[3:1] == 3) || (uart2.IIR[3:1] == 3))
			begin
				if((uart1.LSR[1] == 1) || (uart2.LSR[1] == 1))
					begin
							success++;
					`uvm_info("Score_Board", "OVERRUN ERROR COMPARED", UVM_LOW)
						end
				
				if((uart1.LSR[2] == 1) || (uart2.LSR[2] == 1))
					begin
							success++;
					`uvm_info("Score_Board", "PARITY ERROR COMPARED", UVM_LOW)
						end
			
				if((uart1.LSR[3] == 1) || (uart2.LSR[3] == 1))
					begin
							success++;
					`uvm_info("Score_Board", "FRAMING ERROR COMPARED", UVM_LOW)
						end
				
				if((uart1.LSR[4] == 1) || (uart2.LSR[4] == 1))
					begin
							success++;
					`uvm_info("Score_Board", "BREAK ERROR COMPARED", UVM_LOW)
						end
			end
	
		
		if((uart1.LCR == 8'd11 && uart1.IIR[3:1] == 3'b110) || (uart2.LCR == 8'd11 && uart2.IIR[3:1] == 3'b110))
					begin
							success++;
			`uvm_info("Score_Board", "TIME OUT ERROR COMPARED", UVM_LOW)
						end

		if((uart1.IIR[3:1] == 3'b001) || (uart2.IIR[3:1] == 3'b001))
					begin
							success++;
			`uvm_info("Score_Board", "EMPTY ERROR COMPARED", UVM_LOW)
						end
	
		uartt1.sample;
		uartt2.sample;
		UART1_REGISTER.sample;
		UART2_REGISTER.sample;
	endfunction

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            $display("Number of success  : %0d", success);
            $display("Number of failed : %0d", failed);
        endfunction 
endclass
