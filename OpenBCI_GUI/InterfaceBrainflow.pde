import brainflow.*;
import org.apache.commons.lang3.SystemUtils;

void brainflowTest () {
    try {
        BoardShim board_shim = new BoardShim (-1, "", true);
        board_shim.prepare_session();
        println ("Session is ready");
        board_shim.start_stream (3600);
        println ("Started");
        Thread.sleep (1000);
        board_shim.stop_stream ();
        println ("Stopped");
        println (board_shim.get_board_data_count ());
        println (board_shim.get_board_data ());
        board_shim.release_session ();
        println ("Released");
    }
    catch (Exception e) {
        println("BrainFlow Test Failed");
        e.printStackTrace();
    }
}