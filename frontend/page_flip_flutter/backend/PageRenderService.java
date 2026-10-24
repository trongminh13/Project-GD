package com.example.materials; // đổi theo package của dự án

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.util.Set;
import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.MemoryCacheImageOutputStream;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.common.PDRectangle;
import org.apache.pdfbox.rendering.ImageType;
import org.apache.pdfbox.rendering.PDFRenderer;

/**
 * Vẽ một trang PDF thành JPEG theo chiều rộng cho trước (PDFBox 3.x).
 *
 * <p>CHƯA BIÊN DỊCH VÀ CHƯA CHẠY. Dùng làm điểm xuất phát, kiểm tra với phiên bản
 * PDFBox đang dùng. Nên gọi lúc xuất bản học liệu (tạo sẵn các cỡ ảnh và lưu lại),
 * không gọi khi người dùng đang đọc.
 */
public class PageRenderService {

    /** Chỉ cho phép các cỡ định sẵn để tránh bị lạm dụng và để dễ lưu bộ nhớ đệm. */
    public static final int WIDTH_THUMB = 360;
    public static final int WIDTH_STANDARD = 1080;
    private static final Set<Integer> ALLOWED_WIDTHS = Set.of(WIDTH_THUMB, WIDTH_STANDARD);

    private static final float MAX_DPI = 200f;
    private static final float JPEG_QUALITY = 0.80f;

    public byte[] renderJpeg(Path pdfFile, int pageIndex, int widthPx) throws IOException {
        if (!ALLOWED_WIDTHS.contains(widthPx)) {
            throw new IllegalArgumentException("Chiều rộng không được hỗ trợ: " + widthPx);
        }
        try (PDDocument doc = Loader.loadPDF(pdfFile.toFile())) {
            if (pageIndex < 0 || pageIndex >= doc.getNumberOfPages()) {
                throw new IllegalArgumentException("Trang không tồn tại: " + pageIndex);
            }
            PDPage page = doc.getPage(pageIndex);
            PDRectangle box = page.getCropBox();
            int rotation = page.getRotation();
            float widthPoints = (rotation == 90 || rotation == 270) ? box.getHeight() : box.getWidth();

            float dpi = Math.min(MAX_DPI, widthPx * 72f / widthPoints);
            BufferedImage image = new PDFRenderer(doc).renderImageWithDPI(pageIndex, dpi, ImageType.RGB);
            return toJpeg(image);
        }
    }

    /** Số trang và tỷ lệ rộng/cao từng trang, để app dựng bố cục trước khi ảnh về. */
    public PageInfo[] pageInfos(Path pdfFile) throws IOException {
        try (PDDocument doc = Loader.loadPDF(pdfFile.toFile())) {
            PageInfo[] infos = new PageInfo[doc.getNumberOfPages()];
            for (int i = 0; i < infos.length; i++) {
                PDPage page = doc.getPage(i);
                PDRectangle box = page.getCropBox();
                int rotation = page.getRotation();
                float w = (rotation == 90 || rotation == 270) ? box.getHeight() : box.getWidth();
                float h = (rotation == 90 || rotation == 270) ? box.getWidth() : box.getHeight();
                infos[i] = new PageInfo(i, w / h);
            }
            return infos;
        }
    }

    public record PageInfo(int index, float aspectRatio) {}

    private static byte[] toJpeg(BufferedImage image) throws IOException {
        ImageWriter writer = ImageIO.getImageWritersByFormatName("jpeg").next();
        try (ByteArrayOutputStream out = new ByteArrayOutputStream();
             MemoryCacheImageOutputStream stream = new MemoryCacheImageOutputStream(out)) {
            ImageWriteParam param = writer.getDefaultWriteParam();
            param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
            param.setCompressionQuality(JPEG_QUALITY);
            writer.setOutput(stream);
            writer.write(null, new IIOImage(image, null, null), param);
            stream.flush();
            return out.toByteArray();
        } finally {
            writer.dispose();
        }
    }
}
