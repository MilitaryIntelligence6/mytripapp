package cn.misection.plugin.asr;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * @author Administrator
 */
public class RecogResult {

    private static final int ERROR_NONE = 0;

    private String originalJson;
    private String[] resultsRecognition;
    private String originalResult;

    /**
     * 日志id， 请求有问题请提问带上sn;
     */
    private String logIdSn;
    private String desc;
    private String resultType;
    private int error = -1;
    private int subError = -1;

    public static RecogResult parseJson(String jsonStr) {
        RecogResult result = new RecogResult();
        result.setOriginalJson(jsonStr);
        try {
            JSONObject json = new JSONObject(jsonStr);
            int error = json.optInt("error");
            int subError = json.optInt("sub_error");
            result.setError(error);
            result.setDesc(json.optString("desc"));
            result.setResultType(json.optString("result_type"));
            result.setSubError(subError);
            if (error == ERROR_NONE) {
                result.setOriginalResult(json.getString("origin_result"));
                JSONArray arr = json.optJSONArray("results_recognition");
                if (arr != null) {
                    int size = arr.length();
                    String[] recogs = new String[size];
                    for (int i = 0; i < size; i++) {
                        recogs[i] = arr.getString(i);
                    }
                    result.setResultsRecognition(recogs);
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return result;
    }

    public boolean hasError() {
        return error != ERROR_NONE;
    }

    public boolean isFinalResult() {
        return "final_result".equals(resultType);
    }


    public boolean isPartialResult() {
        return "partial_result".equals(resultType);
    }

    public boolean isNluResult() {
        return "nlu_result".equals(resultType);
    }

    public String getOriginalJson() {
        return originalJson;
    }

    public void setOriginalJson(String originalJson) {
        this.originalJson = originalJson;
    }

    public String[] getResultsRecognition() {
        return resultsRecognition;
    }

    public void setResultsRecognition(String[] resultsRecognition) {
        this.resultsRecognition = resultsRecognition;
    }

    public String getLogIdSn() {
        return logIdSn;
    }

    public void setLogIdSn(String logIdSn) {
        this.logIdSn = logIdSn;
    }

    public int getError() {
        return error;
    }

    public void setError(int error) {
        this.error = error;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public String getOriginalResult() {
        return originalResult;
    }

    public void setOriginalResult(String originalResult) {
        this.originalResult = originalResult;
    }

    public String getResultType() {
        return resultType;
    }

    public void setResultType(String resultType) {
        this.resultType = resultType;
    }

    public int getSubError() {
        return subError;
    }

    public void setSubError(int subError) {
        this.subError = subError;
    }
}
