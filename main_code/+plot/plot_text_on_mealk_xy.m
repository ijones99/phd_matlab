function plot_text_on_mealk_xy(x, y, labels, varargin )

p = inputParser;    % Create an instance of the class.

p.addRequired('x');
p.addRequired('y');
p.addRequired('labels');
p.addRequired('x_offset');
p.addRequired('y_offset');
assert( isrow( labels ) );

p.addParamValue('Prepend',   '');

%p.addParamValue('XScale',   6,  @(x)isnumeric(x) && x>0 && x<=1000);
%p.addParamValue('YScale',   6,  @(x)isnumeric(x) && x>0 && x<=1000);

p.parse(x, y, labels, varargin{:});
args = p.Results;

hold on;
for i = 1:length(labels)
    if isnumeric( labels(i) )
        text( x(i), y(i), [args.Prepend num2str(labels(i))] );
    else
        text( x(i), y(i), [args.Prepend labels(i)] );
    end
end
hold off;

end
