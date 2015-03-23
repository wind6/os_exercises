raw_data = ['va 0xc2265b1f, pa 0x0d8f1b1f', 'va 0xcc386bbc, pa 0x0414cbbc', 'va 0xc7ed4d57, pa 0x07311d57', 'va 0xca6cecc0, pa 0x0c9e9cc0', 'va 0xc18072e8, pa 0x007412e8', 'va 0xcd5f4b3a, pa 0x06ec9b3a', 'va 0xcc324c99, pa 0x0008ac99', 'va 0xc7204e52, pa 0x0b8b6e52', 'va 0xc3a90293, pa 0x0f1fd293', 'va 0xce6c3f32, pa 0x007d4f32']
vaddr = ['0xc2265b1f', '0xcc386bbc', '0xc7ed4d57', '0xca6cecc0', '0xc18072e8', '0xcd5f4b3a', '0xcc324c99', '0xc7204e52', '0xc3a90293', '0xce6c3f32']
paddr = ['0x0d8f1b1f', '0x0414cbbc', '0x07311d57', '0x0c9e9cc0', '0x007412e8', '0x06ec9b3a', '0x0008ac99', '0x0b8b6e52', '0x0f1fd293', '0x007d4f32']

for i in range(0, len(vaddr)):
	pde_idx = int(vaddr[i], 16) >> 22
	pte_idx = (int(vaddr[i], 16) & 0x003fffff) >> 12
	pde_ctx = ((pde_idx + 1) << 12) | 0x003
	pte_ctx = (int(paddr[i], 16) & 0xfffff000) | 0x003
	print "va %s, pa %s, pde_idx 0x%08x, pde_ctx 0x%08x, pte_idx 0x%08x, pte_ctx 0x%08x" %(vaddr[i], paddr[i], pde_idx, pde_ctx, pte_idx, pte_ctx)
