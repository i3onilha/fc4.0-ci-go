package main

import "testing"

func TestSoma(t *testing.T) {
	total := soma(15, 15)
	if total != 30 {
		t.Errorf("deveria ser igual a %d", 30)
	}
}
