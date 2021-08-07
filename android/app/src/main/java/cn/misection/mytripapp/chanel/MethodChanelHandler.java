package cn.misection.mytripapp.chanel;

/**
 * @author Military Intelligence 6 root
 * @version 1.0.0
 * @ClassName MethodChanelHandler
 * @Description TODO
 * @CreateTime 2021年08月07日 23:17:00
 */

import androidx.annotation.NonNull;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * des:
 */
public class MethodChanelHandler implements MethodChannel.MethodCallHandler {

    private MethodChannel channel;

    public MethodChanelHandler(BinaryMessenger messenger) {
        channel = new MethodChannel(messenger, "com.flutter.guide.MethodChannel");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

    }
}
