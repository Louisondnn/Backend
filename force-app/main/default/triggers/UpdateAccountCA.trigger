trigger UpdateAccountCA on Order (after insert, after update) {

th.run;
}
