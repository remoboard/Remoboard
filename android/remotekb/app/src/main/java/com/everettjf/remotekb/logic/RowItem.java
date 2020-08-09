package com.everettjf.remotekb.logic;

public class RowItem {
    public interface TapCallback {
        void onClicked();
    }

    private int imageId;
    private String title;
    private boolean isHeader;
    private TapCallback tapCallback;

    /**
     * row
     * @param imageId
     * @param title
     */
    public RowItem(int imageId, String title, TapCallback callback) {
        this.imageId = imageId;
        this.title = title;
        this.isHeader = false;
        this.tapCallback = callback;
    }

    /**
     * whether section header
     * @param title
     * @param isHeader
     */
    public RowItem(String title, boolean isHeader) {
        this.title = title;
        this.isHeader = isHeader;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getImageId() {
        return imageId;
    }

    public void setImageId(int imageId) {
        this.imageId = imageId;
    }

    public boolean isHeader() {
        return isHeader;
    }

    public void setHeader(boolean header) {
        isHeader = header;
    }

    public TapCallback getTapCallback() {
        return tapCallback;
    }

    public void setTapCallback(TapCallback tapCallback) {
        this.tapCallback = tapCallback;
    }
}
