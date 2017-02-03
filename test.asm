# clear variables
	xor	r5, r5, r5      # running sum
	xor	r0, r0, r0      # loop counter
	xor	r1, r1, r1      # step
	xor	r2, r2, r2      # iterations
	xor	r6, r6, r6      # scratch

	# load test data
	ldi.bh	r6, 1           # memory location = 0x100
	ld.w	r6, @r6         # load it - HB = iterations, LB = step
	mov	r1, r6          # load LB into step
	ldi.bh	r1, 0
	ldi.bl	r5, 8           # shift left by 8 so we can get the HB
	lsr	r2, r6, r5      # load shifted value (HB) directly into the right register
	xor	r5, r5, r5      # reset running sum now that we're done commandeering it

loop:	add	r5, r5, r0      # running sum += loop counter
	add	r0, r0, r1      # loop counter += step
	sub	r4, r0, r2      # if loop counter <= iterations, then loop again
	ble	loop

	sdbi	72              # 0x48, where the LEDs are
	xor	r6, r6, r6
	st.w	@r6, r5         # store sum at 0x480000

forevr:	bra	forevr
	nop
