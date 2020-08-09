package com.everettjf.remotekb.logic;

import android.content.Context;
import android.graphics.Typeface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.everettjf.remotekb.R;

import java.util.List;


public class RowAdapter extends ArrayAdapter<RowItem> {

    private int resourceId;

    public RowAdapter(Context context, int textViewResourceId, List<RowItem> objects) {
        super(context, textViewResourceId, objects);
        this.resourceId = textViewResourceId;
    }


    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        RowItem row = getItem(position);
        View view = LayoutInflater.from(getContext()).inflate(resourceId,parent, false);

        TextView rowText = view.findViewById(R.id.row_title);
        rowText.setText(row.getTitle());

        ImageView rowImage = view.findViewById(R.id.row_image);

        if (row.isHeader()) {
            rowText.setTextSize(17);
            rowText.setTypeface(null, Typeface.BOLD);
        } else {
            rowText.setTextSize(20);
            rowImage.setImageResource(row.getImageId());
        }

        return view;
    }
}