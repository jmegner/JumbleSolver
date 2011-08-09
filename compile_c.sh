#! /bin/bash
gcc `pkg-config --cflags --libs glib-2.0` jumble_solver.c -o jumble_solver_c

