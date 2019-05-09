function f = plot_cold_and_warm(input, mask,crange)
    % PLOT_COLD_AND_WARM - imagesc a matrix with two colorbars.
    %  - input is matrix with values to color
    %  - mask is logical matrix for which colorbar to use at each pixel
    %    true is warm, false is cold
    %  - crange is optional. give [min max] for color bar.
    %  EXAMPLE
    %   a=reshape(1:100,[10 10]);m=a<25 | a>75; plot_cold_and_warm(a,m,[0 100])

    % https://www.mathworks.com/matlabcentral/answers/194554-how-can-i-use-and-display-two-different-colormaps-on-the-same-figure
    % start a new figure and get two axes to plot on
    f=figure;
   
    % first is cold
    ax1=axes('Parent',f);
	img_cool = imagesc(input);
	
    % second is warm
    ax2=axes('Parent',f);
    img_hot = imagesc(input);

    % link them and only show one axis
    linkaxes([ax1 ax2]);
    ax2.Visible = 'off';

    % set colors and range
    colormap(ax1,'winter');
    colormap(ax2,'autumn');

    % if we were given a color range
    if(nargin ==3)
        caxis(ax1,crange)
        caxis(ax2,crange)
    end

    % display colorbars
    set([ax1,ax2],'Position',[.17 .11 .685 .815]);
    colorbar(ax1,'Position',[.05 .11 .0675 .815]);
    colorbar(ax2,'Position',[.88 .11 .0675 .815]);
    
    % set opacity -- remove zero values from view
    % dont show warm when mask is zero (hide warm on cold pixels)
    % dont show cold when mask is one (hide cold on warm pixels)
    isnan(input)
    set(img_hot,'AlphaData', mask & ~isnan(input))
    set(img_cool,'AlphaData', ~mask & ~isnan(input))
end