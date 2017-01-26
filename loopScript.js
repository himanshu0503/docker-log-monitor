function loop() {
	setTimeout(
    function(){
      console.log(new Date());
      loop();
    }, 1000);
}
loop();