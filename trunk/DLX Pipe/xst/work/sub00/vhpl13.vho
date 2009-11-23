      � H  ��        J�I�         k         G   IEEE       IEEE g     �      IEEE   STD_LOGIC_1164   ALL     g     �      IEEE   STD_LOGIC_ARITH   ALL     g     �      IEEE   STD_LOGIC_UNSIGNED   ALL     g     �      work   Global   all     g     :   DLXPipelined  #) g          *�  2�  U�  y  �A  �i  � � (� L	 o1 �Y �� �� � � *� M� U� x� �A �i �� � q � @	 G� S� [a       "  .�  6�  Y�  }  �)  �Q  �y 	� ,� O� s �A �� �� � q .� Q� Y� |� �) �Q �� �� 	Y  � C� K� Wy _I  q  �  �  �          #)     +  Y  A     g     v  ��          .�     :   clk  .�  A     p     *�      '          A     :   reset  6�  A     p     2�      '          A     S  #     :�  >�         R	 @     :�     @     FQ     ' Q3     Bi  J9      N!     @      FQ     v  �Z     FQ      Y�     @            :   pc_fetch  Y�  A     p     U�     N!          A     S  #     :�  a�         u1 @     ]�     @     iy     ' Q3     e�  ma      qI     @      iy     v  �Z     iy      }     @            :   	pc_decode  }  A     p     y     qI          A     S  #     :�  ��         �Y @     ��     @     ��     ' Q3     ��  ��      �q     @      ��     v  �Z     ��      �)     @            :   
pc_execute  �)  A     p     �A     �q          A     S  #     :�  ��         �� @     �     @     ��     ' Q3     ��  ��      ��     @      ��     v  �Z     ��      �Q     @            :   	pc_memory  �Q  A     p     �i     ��          A     S  #     :�  �!         ީ @     �9     @     ��     ' Q3     �	  ��      ��     @      ��     v  �Z     ��      �y     @            :   pc_writeback  �y  A     p     �     ��          A     S  #     *�  �I        � @     �a     @     �     ' Q3     �1  �      ��     @      �     v  �Z     �     	�     @            :   instruction_fetch 	�  A     p    �     ��          A     S  #     *� q        $� @    �     @    A     ' Q3    Y )     !     @     A     v  �Z    A     ,�     @            :   instruction_decode ,�  A     p    (�    !          A     S  #     *� 4�        H! @    0�     @    <i     ' Q3    8� @Q     D9     @     <i     v  �Z    <i     O�     @            :   instruction_execute O�  A     p    L	    D9          A     S  #     *� W�        kI @    S�     @    _�     ' Q3    [� cy     ga     @     _�     v  �Z    _�     s     @            :   instruction_memory s  A     p    o1    ga          A     S  #     *� z�        �q @    w     @    ��     ' Q3    ~� ��     ��     @     ��     v  �Z    ��     �A     @            :   instruction_writeback �A  A     p    �Y    ��          A     @    �     ' Q3    �) ��     ��     @     �     v  �Z    �     ��     :   dec_instruction_format ��  A     p     ��    ��          A     S  #     *� ��        �	 @    ��     @    �Q     ' Q3    �i �9     �!     @     �Q     v  �Z    �Q     ��     @            :   dec_register_a ��  A     p   ! ��    �!          A     S  #     *� ة        �1 @    ��     @    �y     ' Q3    ܑ �a     �I     @     �y     v  �Z    �y     �     @            :   dec_register_b �  A     p   " �    �I          A     @    ��     ' Q3    �� ��     �     @     ��     v  �Z    ��     q     :   exe_instruction_format q  A     p   % �    �          A     S  #     *� A        &� @    Y     @         ' Q3    ) �     "�     @          v  �Z         .�     @            :   exe_alu_exit .�  A     p   & *�    "�          A     S  #     *� 6i        I� @    2�     @    >9     ' Q3    :Q B!     F	     @     >9     v  �Z    >9     Q�     @            :   exe_register_b Q�  A     p   ' M�    F	          A     :   exe_force_jump Y�  A     p   ( U�     '          A     S  #     :� aa        t� @    ]y     @    i1     ' Q3    eI m     q     @     i1     v  �Z    i1     |�     @            :   exe_pc_for_jump |�  A     p   ) x�    q          A     @    ��     ' Q3    �� �q     �Y     @     ��     v  �Z    ��     �)     :   mem_instruction_format �)  A     p   , �A    �Y          A     S  #     *� ��        �� @    �     @    ��     ' Q3    �� ��     ��     @     ��     v  �Z    ��     �Q     @            :   mem_data_out �Q  A     p   - �i    ��          A     @    �!     ' Q3    �9 �	     ��     @     �!     v  �Z    �!     ��     :   mem_dest_register ��  A     p   . ��    ��          A     S  #     *� ֑        � @    ҩ     @    �a     ' Q3    �y �I     �1     @     �a     v  �Z    �a     ��     @            :   mem_dest_register_data ��  A     p   / �    �1          A     @    ��     ' Q3    �� ��     �     @     ��     v  �Z    ��     	Y     :   wb_instruction_format 	Y  A     p   3 q    �          A     @    )     ' Q3    A      �     @     )     v  �Z    )      �     :   wb_dest_register  �  A     p   4 �    �          A     S  #     *� (�        <! @    $�     @    0i     ' Q3    ,� 4Q     89     @     0i     v  �Z    0i     C�     @            :   wb_dest_register_data C�  A     p   5 @	    89          A     :   wb_dest_register_type K�  A     p   6 G�     '          A     v  �|         Wy     :   register_file_debug Wy  A     p   9 S�    O�          A     :   fp_register_file_debug _I  A     p   : [a    O�          A     P             %     �  Y         �  �  �  q  #) k     �   ZC:/Users/Filippo/XilinxProject/DLXSourceCodeVHDL/DLX 11.1 Rewrite/DLXPipe/DLXPipelined.vhd g  �                DLXPipelined       work      DLXPipelined       work      std_logic_1164       IEEE      standard       std      Global       work